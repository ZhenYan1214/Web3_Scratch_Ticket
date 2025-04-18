import React from 'react';
import Header from './components/Header';
import Hero from './components/Hero';
import Features from './components/Features';

function App() {
  return (
    <div className="min-h-screen bg-gray-50">
      <Header />
      <main>
        <Hero />
        <Features />
      </main>
      <footer className="bg-red-800 text-white py-8">
        <div className="container mx-auto px-6 text-center">
          <p>© 2024 財神存錢罐. All rights reserved.</p>
        </div>
      </footer>
    </div>
  );
}

export default App; 