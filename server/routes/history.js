const express = require('express');
const router = express.Router();
const multibaas = require('../utils/multibaas');

// Get user's deposit history
router.get('/:address', async (req, res) => {
  try {
    const { address } = req.params;
    const { fromBlock } = req.query;

    // Get deposit events from the vault contract
    const events = await multibaas.getEvents(
      process.env.PIGGY_VAULT_ADDRESS,
      'Deposit',
      fromBlock || 0
    );

    // Filter events for the specific user
    const userEvents = events.filter(event => 
      event.returnValues.caller.toLowerCase() === address.toLowerCase()
    );

    res.json({
      status: 'success',
      data: userEvents
    });
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: error.message
    });
  }
});

// Get all transactions for a user
router.get('/:address/transactions', async (req, res) => {
  try {
    const { address } = req.params;
    const transactions = await multibaas.getUserTransactions(address);
    res.json({
      status: 'success',
      data: transactions
    });
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: error.message
    });
  }
});

module.exports = router; 