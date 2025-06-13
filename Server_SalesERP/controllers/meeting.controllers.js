const mongoose = require("mongoose");
const Meeting = require("../lib/models/Meeting");

exports.createMeeting = async (req, res) => {
    try {
        const { userId } = req.user;
        const {
            idController,
            meetingOwner,
            meetingClient,
            meetingDate,
            meetingTime,
            meetingPurpose,
            meetingImportantNotes,
            resdulingPurpose,
            resdulingNotes
        } = req.body;

        const newMeeting = await Meeting.create({
            idController: userId,
            meetingOwner,
            meetingClient,
            meetingDate,
            meetingTime,
            meetingPurpose,
            meetingImportantNotes,
            resdulingPurpose,
            resdulingNotes,
        });

        const savedMeeting = await newMeeting.save();
        res.status(201).json({ message: "Meeting created successfully", data: savedMeeting });
    }catch (error) {
        console.error("Error creating meeting:", error);
        res.status(500).json({ message: "Failed to create meeting", error: error.message });
    }
};

exports.updateMeeting = async (req, res) => {
    try {
        const meetingId = req.params.id;
        const { userId } = req.user;

        const meetingDetails = await Meeting.findById(meetingId);
        if (!meetingDetails) {
            return res.status(204).json({ success: false, message: "Meeting not found" });
        }

        if (!meetingDetails.meetingOwner.equals(new mongoose.Types.ObjectId(userId))) {
            return res.status(401).json({ success: false, message: "Unauthorized Action!" });
        }

        let { meetingDate, ...updateData } = req.body;

        const [day, month, year] = meetingDate.split("/");
        const newDate = new Date(`${year}-${month}-${day}T00:00:00.000Z`).toISOString();
        updateData.meetingDate = newDate;

        const meeting = await Meeting.findByIdAndUpdate(meetingId, updateData, { new: true });
        res.status(200).json({ success: true, meeting, message: "Meeting updated successfully" });

    } catch (error) {
        return res.status(500).json({ success: false, message: error.message });
    }
};

exports.getMeetingDetails = async (req, res) => {
    try {
        const meetingId = req.params.id;

        const meetingDetails = await Meeting.findById(meetingId);
        if (!meetingDetails) {
            return res.status(204).json({ success: false, message: "Meeting not found" });
        }

        res.status(200).json({ success: true, meetingDetails, message: "Meeting details found successfully" });
    } catch (error) {
        return res.status(500).json({ success: false, message: error.message });
    }
};

exports.getAllMeetings = async (req, res) => {
  try {
    if (!req.user || !req.user.userId) {
      console.log('Unauthorized: No valid user found');
      return res.status(401).json({ success: false, message: 'Unauthorized: No valid user found' });
    }

    const { userId } = req.user;
    console.log(`Fetching all meetings for userId: ${userId}`);

    const meetings = await Meeting.find({ idController: userId })
      .sort({ createdAt: -1 });

    if (meetings.length === 0) {
      console.log('No meetings found');
      return res.status(200).json({ success: true, meetings: [], message: 'No meetings found' });
    }

    console.log(`Found ${meetings.length} meetings`);
    res.status(200).json({ success: true, meetings, message: 'Meetings found successfully' });
  } catch (error) {
    console.error('Error fetching meetings:', error.stack);
    return res.status(500).json({ success: false, message: error.message, stack: error.stack });
  }
};

exports.getTodayMeetings = async (req, res) => {
    try {
        const { userId } = req.user;
        const today = new Date();
        const startOfDay = new Date(today.setHours(0, 0, 0, 0));
        const endOfDay = new Date(today.setHours(23, 59, 59, 999));
        
        const meetings = await Meeting.find({
            meetingOwner: userId,
            meetingDate: {
                $gte: startOfDay,
                $lte: endOfDay
            }
        }).populate("meetingClient").sort({ createdAt: -1 });
       
        if (!meetings) {
            return res.status(204).json({ success: false, message: "No meetings found" });
        }
        res.status(200).json({ success: true, meetings, message: "Meetings found successfully" });
    }
    catch (error) {
        return res.status(500).json({ success: false, message: error.message });
    }
};
