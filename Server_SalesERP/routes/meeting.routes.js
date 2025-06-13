const express = require('express');
const router = express.Router();

const { authenticate } = require('../middlewares/authentication');
const {
  createMeeting,
  updateMeeting,
  getMeetingDetails,
  getAllMeetings,
  getTodayMeetings,
} = require('../controllers/meeting.controllers');

router.post('/addmeeting', authenticate, createMeeting);
router.put('/:id/updatemeeting', authenticate, updateMeeting);

router.get('/getmeeting/:id', getMeetingDetails);
router.get('/getallmeetings', getAllMeetings);
router.get('/gettodaymeetings/:id', getTodayMeetings);

module.exports = router;
