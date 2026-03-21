import { motion } from "framer-motion";

export default function Login() {
  return (
    <div
      className="relative min-h-screen w-full overflow-hidden"
      style={{
        background:
          "linear-gradient(135deg, #ffffff 0%, #EEF2FF 55%, #EEF2FF 100%)",
      }}
    >
      {/* ================= BACKGROUND ================= */}

      {/* Soft blurred blobs */}
      <div className="pointer-events-none absolute inset-0">
        <div
          className="absolute -top-32 -left-32 w-105 h-105 rounded-full blur-3xl"
          style={{ backgroundColor: "rgba(30,58,138,0.18)" }}
        />
        <div
          className="absolute top-1/3 -right-40 w-115 h-115 rounded-full blur-3xl"
          style={{ backgroundColor: "rgba(30,58,138,0.14)" }}
        />
        <div
          className="absolute -bottom-30 left-1/4 w-95 h-95 rounded-full blur-3xl"
          style={{ backgroundColor: "rgba(30,58,138,0.10)" }}
        />
      </div>

      {/* Decorative symbols (expanded) */}
      <div
        className="pointer-events-none absolute inset-0"
        style={{ color: "rgba(30,58,138,0.35)" }}
      >
        <span className="absolute top-[12%] left-[8%] text-5xl">✦</span>
        <span className="absolute top-[26%] left-[14%] text-3xl">◦</span>
        <span className="absolute top-[42%] left-[6%] text-6xl">✕</span>
        <span className="absolute bottom-[30%] left-[10%] text-4xl">✦</span>
        <span className="absolute bottom-[16%] left-[18%] text-3xl">◦</span>

        <span className="absolute top-[20%] left-[45%] text-4xl">✦</span>
        <span className="absolute top-[50%] left-[38%] text-3xl">◦</span>
        <span className="absolute bottom-[22%] left-[48%] text-5xl">✕</span>

        <span className="absolute top-[14%] right-[10%] text-4xl">◦</span>
        <span className="absolute top-[34%] right-[6%] text-6xl">✕</span>
        <span className="absolute bottom-[28%] right-[14%] text-5xl">✦</span>
        <span className="absolute bottom-[14%] right-[8%] text-3xl">◦</span>
      </div>

      {/* Wavy diagonal line */}
      <svg
        className="pointer-events-none absolute inset-0 w-full h-full"
        viewBox="0 0 1440 900"
        preserveAspectRatio="none"
      >
        <path
          d="M -100 120 C 300 40, 600 220, 900 360 S 1300 720, 1600 920"
          fill="none"
          stroke="rgba(30,58,138,0.35)"
          strokeWidth="2"
        />
      </svg>

      {/* ================= TOP LEFT NAV ================= */}
      <div className="absolute top-6 left-8 z-40">
        <nav className="flex items-center text-sm text-gray-600">
          <span className="mr-1">←</span>
          <span>Home</span>
        </nav>
      </div>

      {/* ================= MAIN CONTENT ================= */}
      <div className="relative flex flex-col items-center text-center px-4 pt-[clamp(4rem,10vh,7rem)]">
        {/* RapidX */}
        <motion.h1
          initial={{ opacity: 0, y: -6 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.5 }}
          className="text-[clamp(2rem,4vw,3rem)] font-semibold tracking-tight text-gray-800 mb-2"
        >
          Rapid
          <span
            style={{ color: "#1E3A8A" }}
            className="text-[clamp(4rem,4vw,3rem)]"
          >
            X
          </span>
        </motion.h1>

        <motion.h2
          initial={{ opacity: 0, y: 10 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6 }}
          className="text-[clamp(1.4rem,2.6vw,2rem)] font-semibold text-gray-800"
        >
          Let’s get you back into the flow
        </motion.h2>

        <p className="mt-2 text-[clamp(0.8rem,1.1vw,0.95rem)] text-gray-500 max-w-xl">
          Everything you need is right where you left it — projects, orders, and
          insights, all in one calm, powerful workspace.
        </p>

        {/* Login Card */}
        <div className="mt-10 w-full flex justify-center pb-16">
          <motion.div
            initial={{ opacity: 0, y: 18 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.6 }}
            className="w-full max-w-md bg-white rounded-3xl px-8 py-8 shadow-[0_24px_48px_rgba(0,0,0,0.10)]"
          >
            <div className="text-center mb-6">
              <h3 className="text-lg font-medium text-gray-800">
                Sign in to continue
              </h3>
              <p className="text-sm text-gray-400">
                Access your RapidX workspace securely.
              </p>
            </div>

            <form className="space-y-5">
              {/* EMAIL FIELD WITH SVG ICON */}
              <div className="relative group">
                <span className="absolute left-4 top-1/2 -translate-y-1/2 text-gray-400 group-focus-within:text-[#1E3A8A] transition">
                  <svg
                    width="18"
                    height="18"
                    viewBox="0 0 24 24"
                    fill="currentColor"
                  >
                    <path d="M12 12c2.761 0 5-2.239 5-5s-2.239-5-5-5-5 2.239-5 5 2.239 5 5 5z" />
                    <path d="M4 20c0-4.418 3.582-8 8-8s8 3.582 8 8v1H4v-1z" />
                  </svg>
                </span>

                <input
                  type="email"
                  placeholder="name@company.com"
                  className="w-full rounded-xl border border-gray-300 pl-11 pr-4 py-3 text-sm
               focus:outline-none focus:border-[#1E3A8A]"
                />
              </div>

              {/* PASSWORD FIELD WITH SVG ICON (open-top lock style) */}
              <div className="relative group">
                <span className="absolute left-4 top-1/2 -translate-y-1/2 text-gray-400 group-focus-within:text-[#1E3A8A] transition">
                  <svg
                    width="18"
                    height="18"
                    viewBox="0 0 24 24"
                    fill="currentColor"
                  >
                    <path d="M17 8h-1V6a4 4 0 00-8 0v2H7a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2V10a2 2 0 00-2-2zm-7-2a2 2 0 114 0v2h-4V6z" />
                  </svg>
                </span>

                <input
                  type="password"
                  placeholder="••••••••••"
                  className="w-full rounded-xl border border-gray-300 pl-11 pr-4 py-3 text-sm
               focus:outline-none focus:border-[#1E3A8A]"
                />
              </div>

              <motion.button
                whileHover={{ scale: 1.02 }}
                whileTap={{ scale: 0.96 }}
                className="w-full rounded-2xl py-3.5 text-white font-medium"
                style={{
                  backgroundColor: "#1E3A8A",
                  boxShadow: "0 14px 28px rgba(30,58,138,0.45)",
                }}
              >
                Take me in
              </motion.button>
            </form>

            <div className="mt-6 flex justify-between text-sm text-gray-500">
              <button style={{ color: "#1E3A8A" }}>Forgot password?</button>
              <button style={{ color: "#1E3A8A" }}>Create account</button>
            </div>
          </motion.div>
        </div>
      </div>
    </div>
  );
}
