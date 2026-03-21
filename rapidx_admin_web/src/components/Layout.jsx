import React, { useState, useEffect } from 'react';
import { Outlet } from 'react-router-dom';
import Sidebar from './Sidebar';
import Header from './Header';

const Layout = () => {
    const [sidebarOpen, setSidebarOpen] = useState(true);
    const [isDarkMode, setIsDarkMode] = useState(() => {
        const savedTheme = localStorage.getItem('admin_theme');
        return savedTheme ? savedTheme === 'dark' : true;
    });

    useEffect(() => {
        if (isDarkMode) {
            document.body.classList.remove('light-mode');
            localStorage.setItem('admin_theme', 'dark');
        } else {
            document.body.classList.add('light-mode');
            localStorage.setItem('admin_theme', 'light');
        }
    }, [isDarkMode]);

    const toggleTheme = () => {
        setIsDarkMode(!isDarkMode);
    };

    const toggleSidebar = () => {
        setSidebarOpen(!sidebarOpen);
    };

    return (
        <div className="app-container fade-in">
            <Sidebar isOpen={sidebarOpen} />
            <main className={`main-content ${!sidebarOpen ? 'expanded' : ''}`}>
                <Header 
                    toggleSidebar={toggleSidebar} 
                    isDarkMode={isDarkMode} 
                    toggleTheme={toggleTheme} 
                />
                <div className="page-container fade-in">
                    <Outlet />
                </div>
            </main>
        </div>
    );
};

export default Layout;
