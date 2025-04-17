const express = require('express');
const router = express.Router();
const { webhookMiddleware } = require('../utils/verifyWebhook');

// Handle MultiBaas webhooks
router.post('/', webhookMiddleware, async (req, res) => {
  try {
    const event = req.body;
    
    // Log the event
    console.log('Received webhook event:', {
      type: event.type,
      address: event.address,
      transactionHash: event.transactionHash,
      blockNumber: event.blockNumber,
      timestamp: event.timestamp
    });

    // Here you would typically:
    // 1. Validate the event data
    // 2. Process the event based on its type
    // 3. Update your database or trigger other actions
    // 4. Notify relevant parties

    // For now, we'll just acknowledge receipt
    res.json({
      status: 'success',
      message: 'Webhook received and processed'
    });
  } catch (error) {
    console.error('Webhook processing error:', error);
    res.status(500).json({
      status: 'error',
      message: error.message
    });
  }
});

module.exports = router; 