import { APP_NAME } from '../lib/config';

export default function Navbar({ walletInfo, onConnect, onDisconnect }) {
  return (
    <nav className="navbar">
      <div className="navbar-brand">
        <h1>{APP_NAME}</h1>
      </div>
      <div className="navbar-menu">
        {!walletInfo ? (
          <button className="connect-wallet" onClick={onConnect}>
            Connect Wallet
          </button>
        ) : (
          <button onClick={onDisconnect}>
            Disconnect: {walletInfo.address.slice(0, 6)}...{walletInfo.address.slice(-4)}
          </button>
        )}
      </div>
    </nav>
  );
}
