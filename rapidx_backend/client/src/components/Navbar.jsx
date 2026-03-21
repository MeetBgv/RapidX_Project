import { useState } from "react";
import Logo from "../images/Logo.svg";
import { motion, AnimatePresence } from "framer-motion";

const Navbar = () => {
  const [dropdown, setDropdown] = useState(false);

  return (
    <nav className="w-full bg-white border-b border-b-gray-200 flex justify-between items-center px-4 py-4">
      <div>
        <img src={Logo} alt="" className="h-10 w-auto" />
      </div>

      <div className="flex justify-around w-[38vw] baloo-2 text-lg">

        {/* ===== SERVICES WITH DROPDOWN ===== */}
        <div
          className="relative"
          onMouseEnter={() => setDropdown(true)}
          onMouseLeave={() => setDropdown(false)}
        >
          <motion.span
            className={`hover:cursor-pointer flex items-center ${dropdown ? "text-[#56a3a6]" : "text-[#000000]"} hover:underline`}
            whileHover={{ scale: 1.01 }}
            whileTap={{ scale: 0.95 }}
            transition={{ duration: 0.1 }}
          >
            Services{" "}
            <motion.svg
              xmlns="http://www.w3.org/2000/svg"
              height="24px"
              viewBox="0 -960 960 960"
              width="24px"
              fill={dropdown ? "#56a3a6" : "#000000"}
              animate={{ rotate: dropdown ? 180 : 0 }}
              transition={{ duration: 0.2 }}
            >
             <path d="M480-360 280-560h400L480-360Z" />
            </motion.svg>
          </motion.span>

          <AnimatePresence>
            {dropdown && (
              <motion.div
                initial={{ opacity: 0, y: -10 }}
                animate={{ opacity: 1, y: 0 }}
                exit={{ opacity: 0, y: -10 }}
                transition={{ duration: 0.2 }}
                className="absolute top-8 left-0 bg-white border border-gray-200 rounded-md shadow-md w-56 overflow-hidden z-50"
              >
                <motion.div
                  whileHover={{ backgroundColor: "#f0f9fa" }}
                  className="px-4 py-2 bg-white hover:text-[#56a3a6] cursor-pointer"
                >
                  E-Commerce & D2C
                </motion.div>

                <motion.div
                  whileHover={{ backgroundColor: "#f0f9fa" }}
                  className="px-4 py-2 bg-white hover:text-[#56a3a6] cursor-pointer"
                >
                  On Demand Service
                </motion.div>
              </motion.div>
            )}
          </AnimatePresence>
        </div>

        {/* ===== OTHER NAV ITEMS ===== */}
        <motion.span
          className="hover:cursor-pointer hover:text-[#56a3a6] hover:underline"
          whileHover={{ scale: 1.02 }}
          whileTap={{ scale: 0.98 }}
          transition={{ duration: 0.1 }}
        >
          Track Orders
        </motion.span>

        <motion.span
          className="hover:cursor-pointer hover:text-[#56a3a6] hover:underline"
          whileHover={{ scale: 1.02 }}
          whileTap={{ scale: 0.98 }}
          transition={{ duration: 0.1 }}
        >
          Delivery Partners
        </motion.span>

        <motion.span
          className="hover:cursor-pointer hover:text-[#56a3a6] hover:underline"
          whileHover={{ scale: 1.02 }}
          whileTap={{ scale: 0.98 }}
          transition={{ duration: 0.1 }}
        >
          About Us
        </motion.span>
      </div>

      {/* ===== BUTTONS ===== */}
      <div className="mr-4 flex justify-between baloo-2 text-xl">
        <motion.button
          className="px-5 py-1 rounded-4xl border mr-2 bg-[#234c6a] text-white hover:bg-white hover:border-[#234c6a] hover:text-[#234c6a] hover:cursor-pointer"
          whileHover={{ scale: 1.05 }}
          whileTap={{ scale: 0.95 }}
          transition={{ duration: 0.1 }}
        >
          Login
        </motion.button>

        <motion.button
          className="px-5 rounded-4xl border ml-2 border-[#234c6a] bg-white text-[#234c6a] hover:bg-[#234c6a] hover:border-white hover:text-white hover:cursor-pointer"
          whileHover={{ scale: 1.05 }}
          whileTap={{ scale: 0.95 }}
          transition={{ duration: 0.1 }}
        >
          Register
        </motion.button>
      </div>
    </nav>
  );
};

export default Navbar;
