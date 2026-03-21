import { useState } from "react";
import {stateCityMap} from "../data/StateCityMap";

export const useStateCity = () => {
    const [state, setState] = useState("");
    const [city, setCity] = useState("");

    const states = Object.keys(stateCityMap);

    const cities = state ? stateCityMap[state] : [];

    const handleStateChange = (value) => {
        setState(value);
        setCity("");
    };

    const handleCityChange = (value) => {
        setCity(value);
    };

    return {
        state,
        city,
        states,
        cities,
        handleStateChange,
        handleCityChange
    };
};