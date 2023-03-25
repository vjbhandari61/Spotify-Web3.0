const mongoose = require('mongoose');

module.exports = async() => {
    try {
        await mongoose.connect(process.env.DB);
        console.log("Connection established successfully!");
    } catch (error) {
        console.log("Connection failed!");
    }
}