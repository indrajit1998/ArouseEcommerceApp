const mongoose = require("mongoose");

const MeetingSchema = new mongoose.Schema({
    idController: {
        type: mongoose.Schema.Types.ObjectId,
        ref: "User",
        required: true
    },
    meetingOwner: {
        type: String,
        required: true
    },
    meetingClient: {
        type: String, 
        required: true
    },
    meetingDate: { type: Date, required: true },
    meetingTime: { type: String, required: true },
    meetingPurpose: { type: String, required: true },
    meetingImportantNotes: { type: String, default: "" },
    resdulingPurpose: { type: String, default: "" },
    resdulingNotes: { type: String, default: "" },
    createdAt: { type: Date, default: Date.now },
    updatedAt: { type: Date, default: Date.now }
});

const Meeting = mongoose.model('Meeting', MeetingSchema);
module.exports = Meeting;
