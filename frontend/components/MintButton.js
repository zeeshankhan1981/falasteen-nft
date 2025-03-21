import { NFT_PRICE } from '../lib/config';

export default function MintButton({ onClick, disabled, loading }) {
  return (
    <button 
      className="mint-button" 
      onClick={onClick} 
      disabled={disabled || loading}
    >
      {loading ? "Processing..." : `Mint NFT for ${NFT_PRICE} MATIC`}
    </button>
  );
}
