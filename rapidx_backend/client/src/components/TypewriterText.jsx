import { useState, useEffect } from "react";
import { motion } from "framer-motion";

const words = ["Mile by Mile", "Path by Path", "Street by Street"];

function TypewriterText() {
  const [text, setText] = useState("");
  const [wordIndex, setWordIndex] = useState(0);
  const [isDeleting, setIsDeleting] = useState(false);

  useEffect(() => {
    const currentWord = words[wordIndex];
    let timeout;

    if (!isDeleting) {
      // Typing
      timeout = setTimeout(() => {
        setText(currentWord.substring(0, text.length + 1));
      }, 120);
    } else {
      // Deleting
      timeout = setTimeout(() => {
        setText(currentWord.substring(0, text.length - 1));
      }, 80);
    }

    // When word is fully typed
    if (!isDeleting && text === currentWord) {
      timeout = setTimeout(() => setIsDeleting(true), 1000);
    }

    // When word is fully deleted
    if (isDeleting && text === "") {
      setIsDeleting(false);
      setWordIndex((prev) => (prev + 1) % words.length);
    }

    return () => clearTimeout(timeout);
  }, [text, isDeleting, wordIndex]);

  return (
    <h2 className="text-4xl font-bold text-[#F4A261]">
      {text}
      <motion.span className=" font-medium"
      transition={{ duration: 0.5, repeat: Infinity, repeatDelay: 0.1, ease: "easeInOut"}}
      animate={{ opacity: [1, 0, 1] }}
      >|</motion.span>
    </h2>
  );
}

export default TypewriterText;
