// API route for serving NFT metadata
export default function handler(req, res) {
  const { id } = req.query;
  
  // Get the host from the request
  const host = req.headers.host;
  const protocol = req.headers['x-forwarded-proto'] || 'http';
  const baseUrl = `${protocol}://${host}`;
  
  // Define metadata for each NFT
  const metadata = {
    1: {
      name: "Falasteen Child NFT",
      description: "Support Palestine by minting this NFT. All proceeds go directly to charity.",
      image: `${baseUrl}/img/falasteen-child-nft.png`,
      attributes: [
        {
          trait_type: "Cause",
          value: "Palestine Relief"
        }
      ]
    },
    2: {
      name: "Falasteen Brutal NFT",
      description: "Support Palestine by minting this NFT. All proceeds go directly to charity.",
      image: `${baseUrl}/img/falasteen-brutal.png`,
      attributes: [
        {
          trait_type: "Cause",
          value: "Palestine Relief"
        }
      ]
    },
    3: {
      name: "Falasteen NFT",
      description: "Support Palestine by minting this NFT. All proceeds go directly to charity.",
      image: `${baseUrl}/img/falasteen-nft.png`,
      attributes: [
        {
          trait_type: "Cause",
          value: "Palestine Relief"
        }
      ]
    }
  };

  // Return 404 if ID doesn't exist
  if (!metadata[id]) {
    return res.status(404).json({ error: "NFT not found" });
  }

  // Set CORS headers to allow access from any origin
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
  
  // Return the metadata
  res.status(200).json(metadata[id]);
}
