import React from 'react';
import { FaShieldAlt, FaChartBar, FaLock, FaGift } from 'react-icons/fa';

const features = [
  {
    icon: <FaShieldAlt className="text-4xl text-red-600" />,
    title: '安全可靠',
    description: '採用先進的區塊鏈技術，確保資金安全'
  },
  {
    icon: <FaChartBar className="text-4xl text-red-600" />,
    title: '智能理財',
    description: '自動化投資策略，最大化收益'
  },
  {
    icon: <FaLock className="text-4xl text-red-600" />,
    title: '私密保護',
    description: '完善的隱私保護機制，保障用戶權益'
  },
  {
    icon: <FaGift className="text-4xl text-red-600" />,
    title: '獎勵機制',
    description: '豐富的獎勵活動，讓存錢更有趣'
  }
];

const Features = () => {
  return (
    <div className="py-16 bg-white">
      <div className="container mx-auto px-6">
        <h2 className="text-3xl font-bold text-center text-red-800 mb-12">
          為什麼選擇財神存錢罐？
        </h2>
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-8">
          {features.map((feature, index) => (
            <div 
              key={index}
              className="p-6 bg-red-50 rounded-lg hover:shadow-lg transition-shadow"
            >
              <div className="flex flex-col items-center text-center">
                <div className="mb-4">{feature.icon}</div>
                <h3 className="text-xl font-semibold text-red-800 mb-2">
                  {feature.title}
                </h3>
                <p className="text-gray-600">
                  {feature.description}
                </p>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
};

export default Features; 