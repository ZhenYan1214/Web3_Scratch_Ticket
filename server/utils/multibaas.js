const axios = require('axios');

class MultiBaasAPI {
  constructor() {
    this.api = axios.create({
      baseURL: process.env.MULTIBAAS_API_URL,
      headers: {
        'Authorization': `Bearer ${process.env.MULTIBAAS_API_KEY}`,
        'Content-Type': 'application/json'
      }
    });
  }

  async getEvents(contractAddress, eventName, fromBlock = 0) {
    try {
      const response = await this.api.get(`/events/${contractAddress}/${eventName}`, {
        params: { fromBlock }
      });
      return response.data;
    } catch (error) {
      console.error('MultiBaas getEvents error:', error);
      throw error;
    }
  }

  async getUserTransactions(address) {
    try {
      const response = await this.api.get(`/address/${address}/transactions`);
      return response.data;
    } catch (error) {
      console.error('MultiBaas getUserTransactions error:', error);
      throw error;
    }
  }

  async watchAddress(address, webhookUrl) {
    try {
      const response = await this.api.post('/webhooks', {
        address,
        url: webhookUrl,
        events: ['Transfer']
      });
      return response.data;
    } catch (error) {
      console.error('MultiBaas watchAddress error:', error);
      throw error;
    }
  }
}

module.exports = new MultiBaasAPI(); 