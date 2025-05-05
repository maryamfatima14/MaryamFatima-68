const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');

const app = express();
app.use(express.json());
app.use(cors({
  origin: '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
}));

const uri = "mongodb://maryam:maryam123@ac-yyjizfx-shard-00-00.y2jyffn.mongodb.net:27017,ac-yyjizfx-shard-00-01.y2jyffn.mongodb.net:27017,ac-yyjizfx-shard-00-02.y2jyffn.mongodb.net:27017/flutterdb?ssl=true&replicaSet=atlas-5c4k94-shard-0&authSource=admin&retryWrites=true&w=majority&appName=Cluster01";

mongoose.connect(uri)
  .then(() => console.log("MongoDB connected successfully"))
  .catch(err => console.error("MongoDB connection error:", err));

const JournalSchema = new mongoose.Schema({
  text: { type: String, required: true },
  mood: { type: String, required: true, enum: ['Happy', 'Sad', 'Neutral', 'Excited', 'Stressed'] },
  createdAt: { type: Date, default: Date.now },
});

const Journal = mongoose.model('Journal', JournalSchema);

app.use((req, res, next) => {
  console.log('Request Body:', req.body);
  next();
});

app.get('/journal', async (req, res) => {
  try {
    const entries = await Journal.find().sort({ createdAt: -1 });
    res.json(entries);
  } catch (err) {
    console.error("Error fetching journal entries:", err);
    res.status(500).json({ error: `Failed to fetch entries: ${err.message}` });
  }
});

app.post('/journal', async (req, res) => {
  try {
    const { text, mood } = req.body;

    console.log('Received data:', { text, mood });

    if (!text || !mood || typeof text !== 'string' || typeof mood !== 'string') {
      return res.status(400).json({ error: "Both text and mood must be non-empty strings" });
    }

    if (!['Happy', 'Sad', 'Neutral', 'Excited', 'Stressed'].includes(mood)) {
      return res.status(400).json({ error: `Invalid mood. Must be one of: ${['Happy', 'Sad', 'Neutral', 'Excited', 'Stressed'].join(', ')}` });
    }

    const entry = new Journal({ text: text.trim(), mood });
    await entry.save();
    res.status(201).json(entry);
  } catch (err) {
    console.error("Error saving journal entry:", err);
    res.status(500).json({ error: `Server error: ${err.message}` });
  }
});

app.put('/journal/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const { text, mood } = req.body;

    if (!text || !mood || typeof text !== 'string' || typeof mood !== 'string') {
      return res.status(400).json({ error: "Both text and mood must be non-empty strings" });
    }

    if (!['Happy', 'Sad', 'Neutral', 'Excited', 'Stressed'].includes(mood)) {
      return res.status(400).json({ error: `Invalid mood. Must be one of: ${['Happy', 'Sad', 'Neutral', 'Excited', 'Stressed'].join(', ')}` });
    }

    const updatedEntry = await Journal.findByIdAndUpdate(id, { text: text.trim(), mood }, { new: true, runValidators: true });
    if (!updatedEntry) {
      return res.status(404).json({ error: 'Entry not found' });
    }
    res.json(updatedEntry);
  } catch (err) {
    console.error("Error updating journal entry:", err);
    res.status(500).json({ error: `Server error: ${err.message}` });
  }
});

app.delete('/journal/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const deletedEntry = await Journal.findByIdAndDelete(id);
    if (!deletedEntry) {
      return res.status(404).json({ error: 'Entry not found' });
    }
    res.status(200).json({ message: 'Entry deleted successfully' });
  } catch (err) {
    console.error("Error deleting journal entry:", err);
    res.status(500).json({ error: `Server error: ${err.message}` });
  }
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, '0.0.0.0', () => console.log(`Server running on port ${PORT}`));