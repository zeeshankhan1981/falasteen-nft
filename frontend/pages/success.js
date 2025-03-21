import { useRouter } from 'next/router';
import { useEffect, useState } from 'react';
import { BLOCK_EXPLORER_URL } from '../lib/config';

export default function Success() {
  const router = useRouter();
  const { tokenId, txHash } = router.query;
  const [countdown, setCountdown] = useState(10);

  useEffect(() => {
    if (!tokenId || !txHash) {
      router.push('/');
      return;
    }

    const timer = setInterval(() => {
      setCountdown((prev) => {
        if (prev <= 1) {
          clearInterval(timer);
          router.push('/');
          return 0;
        }
        return prev - 1;
      });
    }, 1000);

    return () => clearInterval(timer);
  }, [tokenId, txHash, router]);

  return (
    <div className="container">
      <div className="card" style={{ textAlign: 'center', marginTop: '5rem' }}>
        <h1>Thank You for Supporting Palestine!</h1>
        
        <div style={{ margin: '2rem 0' }}>
          <img 
            src="/success.svg" 
            alt="Success" 
            style={{ width: '150px', height: '150px' }} 
          />
        </div>
        
        <h2>Your NFT has been successfully minted!</h2>
        
        <div style={{ margin: '2rem 0' }}>
          <p><strong>Token ID:</strong> {tokenId}</p>
          <p>
            <strong>Transaction:</strong>{' '}
            <a 
              href={`${BLOCK_EXPLORER_URL}/tx/${txHash}`} 
              target="_blank" 
              rel="noopener noreferrer"
            >
              View on Polygonscan
            </a>
          </p>
        </div>
        
        <p>
          100% of your contribution has been sent directly to the charity wallet.
          Thank you for making a difference!
        </p>
        
        <div style={{ marginTop: '2rem' }}>
          <p>Redirecting to home page in {countdown} seconds...</p>
          <button onClick={() => router.push('/')}>
            Return to Home Page
          </button>
        </div>
      </div>
    </div>
  );
}
