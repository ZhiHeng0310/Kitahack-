# 🌱 EcoSnap — Refined & Improved Feature Design

## 🎯 Core Idea (Reframed Clearly)

> Scan an item → AI analyses its potential → Decide the **best value path**:
> **Reuse → Recycle → Sell → Community**, supported by community and tutorials.

This avoids feature collision and makes the app logic *very clear*.

---

## 🧠 1. AI Scan & Product Analysis (Single Source of Truth)

### When user scans an item, the AI produces **ONE analysis result**, not many separate features.

### 🔍 AI Analysis Output

```
Item Detected: Glass Bottle
Material: Glass
Condition: Reusable
Confidence: 93%
```

Then the system branches logically 👇

---

## 🔄 2. Value Path Decision System (No Collision)

After analysis, the app decides **what can be done** with the item.

### Path A — ❌ Cannot Be Reused

If item is:

* Contaminated
* Broken
* Non-reusable material

➡️ **Recycle Path**

**System shows:**

* Recommended recycling method
* Suggested recycling centre (static list)
* Preparation steps (wash, remove label, etc.)

```
This item cannot be reused.
Recommended Action: Recycling
Nearest Centres:
• KL Recycling Hub
• Community E-waste Point
```

✔ Clean
✔ No overlap with selling or tutorials

---

### Path B — ✅ Can Be Reused

If item is reusable, system unlocks **three sub-options**:

---

## ♻️ 3. Reuse Recommendation (Tutorial-Centric)

### Purpose

Help user **transform** the item.

### Shown to user:

* Recommended reuse ideas
* Difficulty level
* Tutorial videos
* Estimated usefulness

Example:

```
Reuse Ideas:
1. Plant Pot (Easy)
2. Desk Organizer (Medium)
3. Decorative Lamp (Hard)

Tutorials:
▶ DIY Bottle Planter
▶ Home Decor from Glass
```

⚠️ At this stage:
❌ No selling yet
❌ No marketplace confusion

Reuse is treated as a **learning & making phase**.

---

## 💰 4. Estimated Market Value (Separated & Clean)

Only shown **after** reuse ideas are displayed.

### AI + Rule-Based Estimation

Uses:

* Item type
* Material
* Condition
* Popularity (from marketplace data)

```
Estimated Market Value After Reuse:
RM 8 – RM 15
```

This answers your requirement:

> “if can, can give estimated market price”

✔ Clear
✔ Logical
✔ Not overlapping with selling UI

---

## 🛒 5. Selling Platform (Triggered by User Intent)

Selling is **optional** and **user-initiated**.

### When user clicks:

> “I want to sell this”

The app opens the **Marketplace Flow**.

---

User fill in details:

* Product title
* Description
* Category
* Suggested price

Example:

```
Title: Handmade Glass Bottle Plant Pot
Price: RM12
Category: Upcycled Home Decor
```

User can edit → publish.

---

### Marketplace Features

* Product listings
* Chat with buyers
* Save items
* Eco-only categories

✔ Selling does not collide with reuse
✔ Reuse can exist without selling

---

## 🌍 6. Community Page (Purpose-Clear)

Instead of being “everything mixed”, the community page has **sections**:

### Community Tabs

1️⃣ Reuse Ideas
2️⃣ Exchange Requests
3️⃣ Success Stories
4️⃣ Tutorials & Tips

Users can:

* Post photos
* Share videos
* Comment
* Like & save ideas

---

## 🏆 7. Impact & Trust System (Optional but Strong)

### Impact Tracker

```
Items Reused: 14
Items Recycled: 9
Items Exchanged: 5
CO₂ Saved: 8.3kg
```

---

### Trust Badges

* Verified Upcycler
* Community Helper
* Eco Seller

This increases safety in selling & exchange.

---

## 🧩 8. Final Clean Feature Map (No Collisions)

```
Scan Item
  ↓
AI Analysis
  ↓
Decision Path
 ├── Recycle → Centre Suggestion
 └── Reusable
      ├── Reuse Tutorials
      ├── Market Price Estimate
      ├── Sell (Community)
```

This structure is:
✔ Logical
✔ Judge-friendly
✔ Developer-friendly

---

## 🏁 Improved One-Liner Pitch

> EcoSnap uses on-device AI to analyse waste, recommend the most valuable action—reuse, sell, exchange, or recycle—and connects users through a sustainability-focused community.

---
