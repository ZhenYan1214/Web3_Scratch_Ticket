import React from 'react';
import { FaCoins } from 'react-icons/fa';

const Header = () => {
  return (
    <header className="bg-gradient-to-r from-red-600 to-red-800 text-white py-4 px-6 shadow-lg">
      <div className="container mx-auto flex items-center justify-between">
        <div className="flex items-center space-x-2">
          <FaCoins className="text-yellow-400 text-3xl animate-bounce" />
          <h1 className="text-2xl font-bold">財神存錢罐</h1>
        </div>
        <nav className="hidden md:flex space-x-6">
          <a href="#" className="hover:text-yellow-300 transition-colors">首頁</a>
          <a href="#" className="hover:text-yellow-300 transition-colors">我的資產</a>
          <a href="#" className="hover:text-yellow-300 transition-colors">存錢記錄</a>
          <a href="#" className="hover:text-yellow-300 transition-colors">關於我們</a>
        </nav>
      </div>
    </header>
  );
};

export default Header; 