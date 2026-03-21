import { useState, useEffect } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { useStateCity } from "../hooks/useStateCity";
import Navbar from "../components/Navbar"
import TypewriterText from "../components/TypewriterText";
import Business_info from "../images/Business_info.svg";
import Address_details from "../images/Address_details.svg";
import Billing_details from "../images/Billing_details.svg";
import Create_password from "../images/Create_password.svg";
import Admin_account from "../images/Admin_account.svg";

const rightVariants = {
  enter: (direction) => ({
    x: direction === 1 ? -60 : 60, // comes from left/right
    opacity: 0,
  }),
  center: { x: 0, opacity: 1 },
  exit: (direction) => ({
    x: direction === 1 ? 60 : -60,
    opacity: 0,
  }),
};

const leftVariants = {
  enter: (direction) => ({
    x: direction === 1 ? 120 : -120, // comes from right/left
    opacity: 0,
  }),
  center: { x: 0, opacity: 1 },
  exit: (direction) => ({
    x: direction === 1 ? -120 : 120,
    opacity: 0,
  }),
};

function BusinessReg() {
  const [step, setStep] = useState(1);
  const [direction, setDirection] = useState(1);
  const [masterValues, setMasterValues] = useState([]);
  const [formData, setFormData] = useState({});
  const [errors, setErrors] = useState({});
  const [isValid, setIsValid] = useState(false);
  const [submitted, setSubmitted] = useState(false);

  const { state, city, states, cities, handleStateChange, handleCityChange } = useStateCity();

  const titles = {
    1: "Business Details",
    2: "Business Address Details",
    3: "Billing Details",
    4: "Create Business Password",
    5: "Business Admin Details",
  };

  const descriptions = {
    1: "Set up your business profile to access our end-to-end logistics network.",
    2: "Provide your business address to enable efficient pickups and deliveries.",
    3: "Provide your billing details to ensure accurate invoices and smooth transactions.",
    4: "Create a secure password to protect your account.",
    5: "Provide business admin details for account management and official communication.",
  };

  const images = {
    1: Business_info,
    2: Address_details,
    3: Billing_details,
    4: Create_password,
    5: Admin_account, 
  };

  const requiredFields = [
  "company_name",
  "business_type_id",
  "reg_no",
  "business_email",
  "business_phone",
  "address",
  "state",
  "city",
  "pincode",
  "billing_cycle_id",
  "payment_method_id",
  "business_password",
  "confirm_business_password",
  "admin_first_name",
  "admin_last_name",
  "admin_email",
  "admin_phone",
  "admin_password",
  "confirm_admin_password",
];

// useEffect(() => {
//   const validateForm = () => {
//     const newErrors = {};

//     if (submitted) {
//       // required fields
//       requiredFields.forEach((field) => {
//         if (!formData[field] || formData[field].trim?.() === "") {
//           newErrors[field] = "This field is required";
//         }
//       });

//       // password match
//       if (
//         formData.business_password &&
//         formData.confirm_business_password &&
//         formData.business_password !== formData.confirm_business_password
//       ) {
//         newErrors.confirm_business_password = "Passwords do not match";
//       }

//       if (
//         formData.admin_password &&
//         formData.confirm_admin_password &&
//         formData.admin_password !== formData.confirm_admin_password
//       ) {
//         newErrors.confirm_admin_password = "Passwords do not match";
//       }

//       // email format
//       if (
//         formData.business_email &&
//         !/\S+@\S+\.\S+/.test(formData.business_email)
//       ) {
//         newErrors.business_email = "Invalid email format";
//       }

//       if (
//         formData.admin_email &&
//         !/\S+@\S+\.\S+/.test(formData.admin_email)
//       ) {
//         newErrors.admin_email = "Invalid email format";
//       }

//       // phone format
//       if (
//         formData.business_phone &&
//         !/^\d{10}$/.test(formData.business_phone)
//       ) {
//         newErrors.business_phone = "Invalid phone number";
//       }

//       if (
//         formData.admin_phone &&
//         !/^\d{10}$/.test(formData.admin_phone)
//       ) {
//         newErrors.admin_phone = "Invalid phone number";
//       }
//     }

//     setErrors(newErrors);
//     setIsValid(Object.keys(newErrors).length === 0);
//   };

//   validateForm();
// }, [formData, submitted]);


const handleSubmit = async (e) => {
  // if(isValid) {
    e.preventDefault();
    try {
      const response = await fetch("http://localhost:3000/api/register/business", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          company_name: formData.company_name,
          business_type_id: formData.business_type_id,
          reg_no: formData.reg_no,
          business_email: formData.business_email,
          business_phone: formData.business_phone,
          address: formData.address,
          city: formData.city,
          state: formData.state,
          pincode: formData.pincode,
          billing_cycle_id: formData.billing_cycle_id,
          payment_method_id: formData.payment_method_id,
          business_password: formData.business_password,
          admin_first_name: formData.admin_first_name,
          admin_last_name: formData.admin_last_name,
          admin_phone: formData.admin_phone,
          admin_email: formData.admin_email,
          admin_password: formData.admin_password
        })
      });
    } catch (error) {
      console.log("Error sending API request to /api/register/business");
    }
  // }
};

  const fetchingMasterValues = async () => {
    try {
      const masterValues = await fetch("http://localhost:3000/api/register/business/master-values", {
        method: "GET",
        headers: {
          "Content-Type": "application/json",
        },
      });

      if(masterValues.ok) {
        const data = await masterValues.json();
        localStorage.setItem("registerMasterValues", JSON.stringify(data));
        console.log("Master values fetched successfully: ", data);
        setMasterValues(data);
        } else {
        console.log("Error in fetching master values: ", masterValues);
      }
    } catch (error) {
      console.log("Error in fetching master values: ", error);
    }
  };

  useEffect(() => {
    const init = async () => {
      const registerMasterValues = localStorage.getItem("registerMasterValues");
      if(!registerMasterValues) {
        await fetchingMasterValues();
      } else {
        setMasterValues(JSON.parse(registerMasterValues));
      }
    }
    init();
  }, []);

  const goNext = (next) => {
    setDirection(1);
    setStep(next);
  };

  const goBack = (prev) => {
    setDirection(-1);
    setStep(prev);
  };

  const inputClass = `peer w-full px-4 py-3 border border-[#275373] rounded-3xl outline-none bg-white text-[#275373] focus:border-[#275373]`;
  const labelClass = `absolute left-4 top-1/2 -translate-y-1/2 text-[#275373] bg-white px-1 pointer-events-none transition-all duration-200 peer-focus:top-0 peer-focus:-translate-y-1/2 peer-focus:text-sm peer-not-placeholder-shown:top-0 peer-not-placeholder-shown:-translate-y-1/2 peer-not-placeholder-shown:text-sm`;

  return (
    <>
  <main className="min-h-screen flex flex-col bg-[linear-gradient(to_bottom_right,#C7E7EB_0%,white_35%,white_65%,#CBDDF2_100%)]">
    <Navbar />

    {/* HERO SECTION */}
    <section className="flex-1 grid grid-cols-2 px-16">

      {/* LEFT SIDE */}
      <div className="flex flex-col justify-center items-center h-full gap-10 baloo-bhai-2">
        <div>
          <h1 className="text-4xl font-bold text-[#234C6A] mb-3">
            Supporting Your Business
          </h1>
          <TypewriterText />
        </div>

        <div className="flex justify-center">
          <AnimatePresence mode="wait" custom={direction}>
            <motion.img
              key={step}
              src={images[step]}
              custom={direction}
              variants={leftVariants}
              initial="enter"
              animate="center"
              exit="exit"
              transition={{ duration: 0.3 }}
              className="w-105"
            />
          </AnimatePresence>
        </div>
      </div>

      {/* RIGHT SIDE */}
      <div className="flex items-center justify-center h-full">
        <div className="flex flex-col justify-between bg-white rounded-2xl shadow-md p-8 baloo-bhai-2">
        <AnimatePresence mode="wait" custom={direction}>
          <motion.h2
            key={step}
            custom={direction}
            variants={rightVariants}
            initial="enter"
            animate="center"
            exit="exit"
            transition={{ duration: 0.3 }}
            className="text-3xl text-[#234c6a] text-center font-extrabold"
          >
          {titles[step]}
          </motion.h2>
        </AnimatePresence>

        <AnimatePresence mode="wait" custom={direction}>
          <motion.h2
            key={step}
            custom={direction}
            variants={leftVariants}
            initial="enter"
            animate="center"
            exit="exit"
            transition={{ duration: 0.3 }}
            className="text-xl text-[#234c6a] text-center font-light mb-8"
          >
          {descriptions[step]}
          </motion.h2>
        </AnimatePresence>
        <AnimatePresence mode="wait" custom={direction}>
        <motion.div
          key={step}
          custom={direction}
          variants={rightVariants}
          initial="enter"
          animate="center"
          exit="exit"
          transition={{ duration: 0.3 }}
          className="flex flex-col justify-between"
        >
        {step === 1 && (
                <>
                  <div className="relative mb-6 w-full">
                    <input type="text" placeholder=" " className={inputClass} value={formData.company_name} onChange={(e) => setFormData({...formData, company_name: e.target.value})} />
                    <label className={labelClass}>Company Name</label>
                  </div>
                  <div className="relative mb-6 w-full">
                  <div className="relative w-full">            
                    <select
                      className={`${inputClass} appearance-none cursor-pointer pr-10`}
                      value={formData.business_type_id}
                      onChange={(e) =>
                        setFormData({ ...formData, business_type_id: e.target.value })
                      }
                    >
                      <option value="" disabled selected>
                        Type of Business
                      </option>
                    
                      {masterValues?.businessType?.map((type) => (
                        <option key={type.value_id} value={type.value_id}>
                          {type.value_name}
                        </option>
                      ))}
                    </select>
                    
                    {/* Custom arrow */}
                    <div className="pointer-events-none absolute inset-y-0 right-4 flex items-center text-[#275373]">
                      <svg
                        xmlns="http://www.w3.org/2000/svg"
                        className="h-5 w-5"
                        viewBox="0 0 20 20"
                        fill="currentColor"
                      >
                        <path
                          fillRule="evenodd"
                          d="M5.23 7.21a.75.75 0 011.06.02L10 10.94l3.71-3.71a.75.75 0 111.06 1.06l-4.24 4.24a.75.75 0 01-1.06 0L5.21 8.29a.75.75 0 01.02-1.08z"
                          clipRule="evenodd"
                        />
                      </svg>
                    </div>
                    
                  </div>

                  </div>
                  <div className="relative mb-6 w-full">
                    <input type="text" placeholder=" " className={inputClass} value={formData.reg_no} onChange={(e) => setFormData({...formData, reg_no: e.target.value})}/>
                    <label className={labelClass}>GST Number</label>
                  </div>
                  <div className="relative mb-6 w-full">
                    <input type="email" placeholder=" " className={inputClass} value={formData.business_email} onChange={(e) => setFormData({...formData, business_email: e.target.value})}/>
                    <label className={labelClass}>Business Email</label>
                  </div>
                  <div className="relative mb-10 w-full">
                    <input type="number" placeholder=" " className={inputClass} value={formData.business_phone} onChange={(e) => setFormData({...formData, business_phone: e.target.value})}/>
                    <label className={labelClass}>Business Phone</label>
                  </div>
                  <motion.button onClick={() => goNext(2)} className="bg-[#275373] text-white py-2 w-2/3 self-center rounded-3xl hover:bg-[#DE9325] hover:text-black hover:cursor-pointer"
                    whileHover={{ scale: 1.03}}
                    whileTap={{ scale: 0.97 }}
                    transition={{ duration: 0.12 }}
                  >
                    Continue →
                  </motion.button>
                </>
              )}

              {step === 2 && (
                <>
                  <div className="relative mb-6 w-full">
                    <input type="text" placeholder=" " className={inputClass} value={formData.address} onChange={(e) => setFormData({...formData, address: e.target.value})}/>
                    <label className={labelClass}>Address</label>
                  </div>
                  <div className="relative mb-6 w-full">
                  <div className="relative w-full">            
                    <select
                      className={`${inputClass} appearance-none cursor-pointer pr-10`}
                      value={formData.state}
                      onChange={(e) => {
                        handleStateChange(e.target.value)
                        setFormData({ ...formData, state: e.target.value })
                      }}>
                      <option value="" disabled selected>
                        Select State
                      </option>
                      {states.map((state) => (
                        <option key={state} value={state}>{state}</option>
                      ))}
                    </select>
                    
                    {/* Custom arrow */}
                    <div className="pointer-events-none absolute inset-y-0 right-4 flex items-center text-[#275373]">
                      <svg
                        xmlns="http://www.w3.org/2000/svg"
                        className="h-5 w-5"
                        viewBox="0 0 20 20"
                        fill="currentColor"
                      >
                        <path
                          fillRule="evenodd"
                          d="M5.23 7.21a.75.75 0 011.06.02L10 10.94l3.71-3.71a.75.75 0 111.06 1.06l-4.24 4.24a.75.75 0 01-1.06 0L5.21 8.29a.75.75 0 01.02-1.08z"
                          clipRule="evenodd"
                        />
                      </svg>
                    </div>
                    
                  </div>
                  </div>
                  <div className="relative mb-6 w-full">
                  <div className="relative w-full">            
                    <select
                      className={`${inputClass} appearance-none cursor-pointer pr-10`}
                      value={formData.city}
                      onChange={(e) => {
                        handleCityChange(e.target.value)
                        setFormData({ ...formData, city: e.target.value })
                      }}>
                      <option value="" disabled selected>
                        Select City
                      </option>
                      {cities.map((city) => (
                        <option key={city} value={city}>{city}</option>
                      ))}
                    </select>
                    
                    {/* Custom arrow */}
                    <div className="pointer-events-none absolute inset-y-0 right-4 flex items-center text-[#275373]">
                      <svg
                        xmlns="http://www.w3.org/2000/svg"
                        className="h-5 w-5"
                        viewBox="0 0 20 20"
                        fill="currentColor"
                      >
                        <path
                          fillRule="evenodd"
                          d="M5.23 7.21a.75.75 0 011.06.02L10 10.94l3.71-3.71a.75.75 0 111.06 1.06l-4.24 4.24a.75.75 0 01-1.06 0L5.21 8.29a.75.75 0 01.02-1.08z"
                          clipRule="evenodd"
                        />
                      </svg>
                    </div>
                    
                  </div>
                  </div>
                  <div className="relative mb-10 w-full">
                    <input type="number" placeholder=" " className={inputClass} value={formData.pincode} onChange={(e) => setFormData({...formData, pincode: e.target.value})}/>
                    <label className={labelClass}>Pincode</label>
                  </div>
                  <div className="flex justify-between">
                    <motion.button onClick={() => goBack(1)} className="bg-[#275373] text-white py-2 rounded-3xl w-[40%] hover:bg-[#DE9325] hover:text-black hover:cursor-pointer"
                      whileHover={{ scale: 1.03}}
                      whileTap={{ scale: 0.97 }}
                      transition={{ duration: 0.12 }}
                    >
                    ← Back
                    </motion.button>
                    <motion.button onClick={() => goNext(3)} className="bg-[#275373] text-white py-2 rounded-3xl w-[40%] hover:bg-[#DE9325] hover:text-black hover:cursor-pointer"
                      whileHover={{ scale: 1.03}}
                      whileTap={{ scale: 0.97 }}
                      transition={{ duration: 0.12 }}
                    >
                    Continue →
                    </motion.button>
                  </div>
                </>
              )}

              {step === 3 && (
                <>
                  <div className="relative mb-6 w-full">
                  <div className="relative w-full">            
                    <select
                      className={`${inputClass} appearance-none cursor-pointer pr-10`}
                      value={formData.billing_cycle_id}
                      onChange={(e) =>
                        setFormData({ ...formData, billing_cycle_id: e.target.value })
                      }
                    >
                      <option value="" disabled selected>
                        Billing Cycle
                      </option>
                    
                      {masterValues?.billingCycle?.map((type) => (
                        <option key={type.value_id} value={type.value_id}>
                          {type.value_name}
                        </option>
                      ))}
                    </select>
                    
                    {/* Custom arrow */}
                    <div className="pointer-events-none absolute inset-y-0 right-4 flex items-center text-[#275373]">
                      <svg
                        xmlns="http://www.w3.org/2000/svg"
                        className="h-5 w-5"
                        viewBox="0 0 20 20"
                        fill="currentColor"
                      >
                        <path
                          fillRule="evenodd"
                          d="M5.23 7.21a.75.75 0 011.06.02L10 10.94l3.71-3.71a.75.75 0 111.06 1.06l-4.24 4.24a.75.75 0 01-1.06 0L5.21 8.29a.75.75 0 01.02-1.08z"
                          clipRule="evenodd"
                        />
                      </svg>
                    </div>
                  </div>
                  </div>
                  <div className="relative mb-10 w-full">
                  <div className="relative w-full">            
                    <select
                      className={`${inputClass} appearance-none cursor-pointer pr-10`}
                      value={formData.payment_method_id}
                      onChange={(e) =>
                        setFormData({ ...formData, payment_method_id: e.target.value })
                      }
                    >
                      <option value="" disabled selected>
                        Payment Method
                      </option>
                    
                      {masterValues?.paymentMethod?.map((type) => (
                        <option key={type.value_id} value={type.value_id}>
                          {type.value_name}
                        </option>
                      ))}
                    </select>
                    
                    {/* Custom arrow */}
                    <div className="pointer-events-none absolute inset-y-0 right-4 flex items-center text-[#275373]">
                      <svg
                        xmlns="http://www.w3.org/2000/svg"
                        className="h-5 w-5"
                        viewBox="0 0 20 20"
                        fill="currentColor"
                      >
                        <path
                          fillRule="evenodd"
                          d="M5.23 7.21a.75.75 0 011.06.02L10 10.94l3.71-3.71a.75.75 0 111.06 1.06l-4.24 4.24a.75.75 0 01-1.06 0L5.21 8.29a.75.75 0 01.02-1.08z"
                          clipRule="evenodd"
                        />
                      </svg>
                    </div>
                  </div>
                  </div>
                  <div className="flex justify-between">
                    <motion.button onClick={() => goBack(2)} className="bg-[#275373] text-white py-2 rounded-3xl w-[40%] hover:bg-[#DE9325] hover:text-black hover:cursor-pointer"
                      whileHover={{ scale: 1.03}}
                      whileTap={{ scale: 0.97 }}
                      transition={{ duration: 0.12 }}
                    >
                    ← Back
                    </motion.button>
                    <motion.button onClick={() => goNext(4)} className="bg-[#275373] text-white py-2 rounded-3xl w-[40%] hover:bg-[#DE9325] hover:text-black hover:cursor-pointer"
                      whileHover={{ scale: 1.03}}
                      whileTap={{ scale: 0.97 }}
                      transition={{ duration: 0.12 }}
                    >
                    Continue →
                    </motion.button>
                  </div>
                </>
              )}

               {step === 4 && (
                <>
                  <div className="relative mb-6 w-full">
                    <input type="password" placeholder=" " className={inputClass} value={formData.business_password} onChange={(e) => setFormData({...formData, business_password: e.target.value})}/>
                    <label className={labelClass}>Enter Password</label>
                  </div>
                  <div className="relative mb-10 w-full">
                    <input type="password" placeholder=" " className={inputClass} value={formData.confirm_business_password} onChange={(e) => setFormData({...formData, confirm_business_password: e.target.value})}/>
                    <label className={labelClass}>Confirm Password</label>
                  </div>
                  <div className="flex justify-between">
                    <motion.button onClick={() => goBack(3)} className="bg-[#275373] text-white py-2 rounded-3xl w-[40%] hover:bg-[#DE9325] hover:text-black hover:cursor-pointer"
                      whileHover={{ scale: 1.03}}
                      whileTap={{ scale: 0.97 }}
                      transition={{ duration: 0.12 }}
                    >
                    ← Back
                    </motion.button>
                    <motion.button onClick={() => goNext(5)} className="bg-[#275373] text-white py-2 rounded-3xl w-[40%] hover:bg-[#DE9325] hover:text-black hover:cursor-pointer"
                      whileHover={{ scale: 1.03}}
                      whileTap={{ scale: 0.97 }}
                      transition={{ duration: 0.12 }}
                    >
                    Continue →
                    </motion.button>
                  </div>
                </>
              )}

              {step === 5 && (
                <>
                  <div className="relative mb-6 w-full">
                    <input type="text" placeholder=" " className={inputClass} value={formData.admin_first_name} onChange={(e) => setFormData({...formData, admin_first_name: e.target.value})}/>
                    <label className={labelClass}>First Name</label>
                  </div>
                  <div className="relative mb-6 w-full">
                    <input type="text" placeholder=" " className={inputClass} value={formData.admin_last_name} onChange={(e) => setFormData({...formData, admin_last_name: e.target.value})}/>
                    <label className={labelClass}>Last Name</label>
                  </div>
                  <div className="relative mb-6 w-full">
                    <input type="email" placeholder=" " className={inputClass} value={formData.admin_email} onChange={(e) => setFormData({...formData, admin_email: e.target.value})}/>
                    <label className={labelClass}>Email</label>
                  </div>
                  <div className="relative mb-6 w-full">
                    <input type="number" placeholder=" " className={inputClass} value={formData.admin_phone} onChange={(e) => setFormData({...formData, admin_phone: e.target.value})}/>
                    <label className={labelClass}>Phone</label>
                  </div>
                  <div className="relative mb-6 w-full">
                    <input type="password" placeholder=" " className={inputClass} value={formData.admin_password} onChange={(e) => setFormData({...formData, admin_password: e.target.value})}/>
                    <label className={labelClass}>Enter Password</label>
                  </div>
                  <div className="relative mb-10 w-full">
                    <input type="password" placeholder=" " className={inputClass} value={formData.confirm_admin_password} onChange={(e) => setFormData({...formData, confirm_admin_password: e.target.value})}/>
                    <label className={labelClass}>Confirm Password</label>
                  </div>
                  <div className="flex justify-between">
                    <motion.button onClick={() => goBack(4)} className="bg-[#275373] text-white py-2 rounded-3xl w-[40%] hover:bg-[#DE9325] hover:text-black hover:cursor-pointer"
                      whileHover={{ scale: 1.03}}
                      whileTap={{ scale: 0.97 }}
                      transition={{ duration: 0.12 }}
                    >
                    ← Back
                    </motion.button>
                    <motion.button onClick={handleSubmit} className="bg-[#275373] text-white py-2 rounded-3xl w-[40%] hover:bg-[#DE9325] hover:text-black hover:cursor-pointer"
                      whileHover={{ scale: 1.03}}
                      whileTap={{ scale: 0.97 }}
                      transition={{ duration: 0.12 }}
                    >
                    Finish Setup
                    </motion.button>
                  </div>
                </>
              )}
        </motion.div>
        </AnimatePresence>
        </div>
      </div>

    </section>
  </main>
</>
  );
}

export default BusinessReg;