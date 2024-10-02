// src/App.js

import React, { useEffect, useState } from "react";
import { BrowserRouter as Router, Routes, Route } from "react-router-dom";
import ConnectWallet from "./components/ConnectWallet";
import PlatformOwner from "./pages/PlatformOwner";
import Creator from "./pages/Creator";
import User from "./pages/User";
import { ethers } from "ethers";

const App = () => {
  const [signer, setSigner] = useState(null);
  const onSignerChanged = (signer) => setSigner(signer);
  useEffect(() => {
    const provider = new ethers.BrowserProvider(window.ethereum);
    provider.getSigner().then(setSigner);
  }, []);
  return (
    <Router>
      <Routes>
        <Route
          path="/"
          element={<ConnectWallet onSignerChanged={onSignerChanged} />}
        />
        <Route path="/owner" element={<PlatformOwner signer={signer} />} />
        <Route path="/creator" element={<Creator signer={signer} />} />
        <Route path="/user" element={<User signer={signer} />} />
      </Routes>
    </Router>
  );
};

export default App;
