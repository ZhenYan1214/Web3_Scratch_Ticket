import React from 'react';
import { FaPiggyBank, FaChartLine } from 'react-icons/fa';

const Hero = () => {
  return (
    <div className="bg-red-50 py-16">
      <div className="container mx-auto px-6">
        <div className="flex flex-col md:flex-row items-center justify-between">
          <div className="md:w-1/2 mb-8 md:mb-0">
            <h2 className="text-4xl md:text-5xl font-bold text-red-800 mb-4">
              讓財神幫你存錢
            </h2>
            <p className="text-lg text-gray-600 mb-8">
              智能理財，安全可靠，讓你的財富穩步增長
            </p>
            <div className="flex space-x-4">
              <button className="bg-red-600 text-white px-6 py-3 rounded-lg hover:bg-red-700 transition-colors flex items-center">
                <FaPiggyBank className="mr-2" />
                開始存錢
              </button>
              <button className="bg-yellow-500 text-white px-6 py-3 rounded-lg hover:bg-yellow-600 transition-colors flex items-center">
                <FaChartLine className="mr-2" />
                查看收益
              </button>
            </div>
          </div>
          <div className="md:w-1/2">
            <img 
              src="/images/fortune-god.png" 
              alt="財神" 
              className="w-full max-w-md mx-auto animate-float"
            />
          </div>
        </div>
      </div>
    </div>
  );
};

export default Hero; 