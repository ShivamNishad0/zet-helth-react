import { useState, useEffect } from 'react';

const useCurrentAddress = () => {
  const [currentAddress, setCurrentAddress] = useState('Select Location');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");

  useEffect(() => {
    // Try to load from localStorage first
    const savedAddress = localStorage.getItem("current_address");
    if (savedAddress) {
      setCurrentAddress(savedAddress);
      return;
    }

    // If not in localStorage, fetch location
    if ("geolocation" in navigator) {
      setLoading(true);
      navigator.geolocation.getCurrentPosition(
        async (position) => {
          const { latitude, longitude } = position.coords;

          try {
            // Reverse geocode using OpenStreetMap's API
            const response = await fetch(
              `https://nominatim.openstreetmap.org/reverse?lat=${latitude}&lon=${longitude}&format=json`
            );
            const data = await response.json();

            const address = data.display_name || "Unable to fetch address";
            setCurrentAddress(address);
            localStorage.setItem("current_address", address); // save it
          } catch (err) {
            setError("Failed to fetch address");
          } finally {
            setLoading(false);
          }
        },
        (err) => {
          setError(err.message);
          setLoading(false);
        }
      );
    } else {
      setError("Geolocation is not supported by your browser.");
    }
  }, []);

  return { currentAddress, loading, error };
};

export default useCurrentAddress;
