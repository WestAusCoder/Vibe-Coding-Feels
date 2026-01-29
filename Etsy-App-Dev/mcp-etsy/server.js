import express from "express";
import axios from "axios";
import dotenv from "dotenv";

dotenv.config();

const ETSY_ACCESS_TOKEN = process.env.ETSY_ACCESS_TOKEN;
const ETSY_SHOP_ID = process.env.ETSY_SHOP_ID;

const app = express();
app.use(express.json());

// Helper function: fetch active listings
async function getListings() {
  const url = `https://openapi.etsy.com/v3/application/shops/${ETSY_SHOP_ID}/listings/active`;
  const res = await axios.get(url, {
    headers: { Authorization: `Bearer ${ETSY_ACCESS_TOKEN}` },
  });
  return res.data.results;
}

// REST endpoint: /get_listings
app.get("/get_listings", async (req, res) => {
  try {
    const listings = await getListings();
    res.json(listings);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Failed to fetch listings" });
  }
});

// Start local server
const PORT = 3333;
app.listen(PORT, () => {
  console.log(`Etsy API proxy running at http://localhost:${PORT}`);
});
