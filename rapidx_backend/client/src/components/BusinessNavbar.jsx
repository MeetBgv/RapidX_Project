import { NavLink } from "react-router-dom";
import { PackagePlus, Boxes, ClipboardClock, ReceiptText, LogOut } from "lucide-react";
import LogoLight from "../images/Logo_Light.svg"

function BusinessNavbar() {
  return (
    <>
    <div className="w-64 min-h-screen bg-[#234C6A] text-white flex flex-col">

      {/* Logo */}
      <div className="p-6 text-2xl font-bold border-b border-[#E7E7E7]/50">
        <img src={LogoLight} alt="" className="h-10 w-auto" />
      </div>

      {/* Menu */}
      <nav className="flex-1 px-3 py-4 space-y-2">

        <NavLink
          to="/create/order"
          className={({ isActive }) =>
            `flex items-center gap-3 px-4 py-2 rounded-lg transition
             ${isActive ? "bg-[#E7E7E7] text-[#234C6A]" : "hover:bg-white/10"}`
          }
        >
          <PackagePlus size={20} />
          Create Order
        </NavLink>

        <NavLink
          to="/business/orders"
          className={({ isActive }) =>
            `flex items-center gap-3 px-4 py-2 rounded-lg transition
             ${isActive ? "bg-[#E7E7E7] text-[#234C6A]" : "hover:bg-white/10"}`
          }
        >
          <Boxes size={20} />
          Orders
        </NavLink>

        <NavLink
          to="/order/history"
          className={({ isActive }) =>
            `flex items-center gap-3 px-4 py-2 rounded-lg transition
             ${isActive ? "bg-[#E7E7E7] text-[#234C6A]" : "hover:bg-white/10"}`
          }
        >
          <ClipboardClock size={20} />
          Order History
        </NavLink>

        <NavLink
          to="/payments"
          className={({ isActive }) =>
            `flex items-center gap-3 px-4 py-2 rounded-lg transition
             ${isActive ? "bg-[#E7E7E7] text-[#234C6A]" : "hover:bg-white/10"}`
          }
        >
          <ReceiptText size={20} />
          Billings & Payments
        </NavLink>
      </nav>

      {/* Logout */}
      <div className="p-4 border-t border-[#E7E7E7]/50">
        <button className="flex items-center gap-3 w-full px-4 py-2 rounded-lg hover:bg-white/20">
          <LogOut size={20} />
          Logout
        </button>
      </div>
    </div>
    </>
  )
}

export default BusinessNavbar
