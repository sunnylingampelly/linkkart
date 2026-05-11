import React from 'react';
import { Link } from 'react-router-dom';

function NotFoundPage() {
  return (
    <div style={{
      display: 'flex',
      flexDirection: 'column',
      alignItems: 'center',
      justifyContent: 'center',
      minHeight: '100vh',
      padding: '2rem',
      textAlign: 'center',
      background: '#000',
      color: 'white',
      fontFamily: 'var(--font-sans)'
    }}>
      <h1 style={{ 
        fontSize: '8rem', 
        margin: 0, 
        color: 'var(--secondary)', 
        fontFamily: 'var(--font-serif)',
        letterSpacing: '-5px' 
      }}>404</h1>
      <h2 style={{ 
        fontSize: '2rem', 
        marginBottom: '1.5rem',
        textTransform: 'uppercase',
        letterSpacing: '4px'
      }}>Page Not Found</h2>
      <p style={{ color: 'var(--gray-500)', marginBottom: '3rem', letterSpacing: '1px' }}>
        THE REQUESTED RESOURCE HAS ELUDED OUR COLLECTION.
      </p>
      <Link 
        to="/" 
        style={{
          background: 'var(--secondary)',
          color: 'black',
          padding: '18px 40px',
          borderRadius: '0',
          textDecoration: 'none',
          fontWeight: 800,
          textTransform: 'uppercase',
          letterSpacing: '2px',
          fontSize: '12px'
        }}
      >
        Return to Home
      </Link>
    </div>
  );
}

export default NotFoundPage;
