import React from 'react';
import { BrowserRouter, Routes, Route } from 'react-router-dom';
import Layout from './components/Layout';
import Dashboard from './pages/Dashboard';
import Users from './pages/Users';
import Businesses from './pages/Businesses';
import DeliveryPartners from './pages/DeliveryPartners';
import Orders from './pages/Orders';
import Parcels from './pages/Parcels';
import Payments from './pages/Payments';
import Payouts from './pages/Payouts';
import Billing from './pages/Billing';
import Complaints from './pages/Complaints';
import MasterData from './pages/MasterData';
import Roles from './pages/Roles';
import Settings from './pages/Settings';

function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<Layout />}>
          <Route index element={<Dashboard />} />
          <Route path="users" element={<Users />} />
          <Route path="businesses" element={<Businesses />} />
          <Route path="partners" element={<DeliveryPartners />} />
          <Route path="orders" element={<Orders />} />
          <Route path="parcels" element={<Parcels />} />
          <Route path="payments" element={<Payments />} />
          <Route path="payouts" element={<Payouts />} />
          <Route path="billing" element={<Billing />} />
          <Route path="complaints" element={<Complaints />} />
          <Route path="master-data" element={<MasterData />} />
          <Route path="roles" element={<Roles />} />
          <Route path="settings" element={<Settings />} />
        </Route>
      </Routes>
    </BrowserRouter>
  );
}

export default App;
