/**
 * Script to upload NFT images and metadata to IPFS
 * 
 * Prerequisites:
 * 1. Install IPFS CLI: https://docs.ipfs.io/install/command-line/
 * 2. Start IPFS daemon: ipfs daemon
 * 3. Install dependencies: npm install ipfs-http-client fs-extra
 */

const { create } = require('ipfs-http-client');
const fs = require('fs-extra');
const path = require('path');

// Connect to local IPFS daemon
const ipfs = create({ host: 'localhost', port: 5001, protocol: 'http' });

async function uploadDirectory(dirPath) {
  try {
    console.log(`Uploading directory: ${dirPath}`);
    
    // Add the directory to IPFS
    const result = await ipfs.add(
      ipfs.globSource(dirPath, { recursive: true }),
      { pin: true }
    );
    
    // The last item in the result will be the directory CID
    let dirCid = null;
    for await (const file of result) {
      console.log(`Added ${file.path} - CID: ${file.cid.toString()}`);
      dirCid = file.cid.toString();
    }
    
    console.log(`\nDirectory CID: ${dirCid}`);
    return dirCid;
  } catch (error) {
    console.error('Error uploading to IPFS:', error);
    throw error;
  }
}

async function updateMetadataWithImageCID(imagesCID) {
  const metadataDir = path.join(__dirname, 'metadata');
  const files = await fs.readdir(metadataDir);
  
  for (const file of files) {
    if (file.endsWith('.json')) {
      const filePath = path.join(metadataDir, file);
      const metadata = await fs.readJson(filePath);
      
      // Update the image URL with the correct CID
      const imageName = path.basename(metadata.image).split('/').pop();
      metadata.image = `ipfs://${imagesCID}/images/${imageName}`;
      
      // Write the updated metadata back to the file
      await fs.writeJson(filePath, metadata, { spaces: 2 });
      console.log(`Updated metadata for ${file}`);
    }
  }
}

async function main() {
  try {
    // First, upload the images directory
    console.log('Uploading images to IPFS...');
    const imagesDir = path.join(__dirname, 'images');
    const imagesCID = await uploadDirectory(imagesDir);
    
    // Update metadata files with the images CID
    console.log('\nUpdating metadata with image CID...');
    await updateMetadataWithImageCID(imagesCID);
    
    // Then, upload the metadata directory
    console.log('\nUploading metadata to IPFS...');
    const metadataDir = path.join(__dirname, 'metadata');
    const metadataCID = await uploadDirectory(metadataDir);
    
    console.log('\n=== IPFS Upload Complete ===');
    console.log(`Images CID: ${imagesCID}`);
    console.log(`Metadata CID: ${metadataCID}`);
    console.log('\nUse these CIDs to update your frontend config.js and smart contract deployment.');
    
  } catch (error) {
    console.error('Error in main process:', error);
  }
}

main();
