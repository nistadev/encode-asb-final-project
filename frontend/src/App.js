// src/App.js

import React from "react";
import { BrowserRouter as Router, Routes, Route } from "react-router-dom";
import ConnectWallet from "./components/ConnectWallet";
import PlatformOwner from "./pages/PlatformOwner";
import Creator from "./pages/Creator";
import User from "./pages/User";

const App = () => {
  return (
    <Router>
      <Routes>
        <Route path="/" element={<ConnectWallet />} />
        <Route path="/owner" element={<PlatformOwner />} />
        <Route path="/creator" element={<Creator />} />
        <Route path="/user" element={<User />} />
      </Routes>
    </Router>
  );
};

export default App;
