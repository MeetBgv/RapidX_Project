import { Route, Routes } from "react-router";
import Login from "../pages/Login";
import BusinessRegister from "../pages/BusinessRegister";
import BusinessDashboard from "../pages/BusinessDashboard";

function AllRoutes() {
  return (
    <>
        <Routes>
            <Route path='/login' element={<Login />}></Route>
            <Route path='/register/business' element={<BusinessRegister />}></Route>
            <Route path='/business/dashboard' element={<BusinessDashboard />}></Route>
        </Routes>
    </>
  )
}

export default AllRoutes