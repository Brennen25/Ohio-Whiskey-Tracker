import React, { useEffect, useState } from 'react';
import MapComponent from './MapComponent';
import LocationList from './LocationList';

const App = () => {
    const [locations, setLocations] = useState([]);
    const [isLoading, setIsLoading] = useState(true);

    useEffect(() => {
        const fetchLocations = async () => {
            setIsLoading(true);
            try {
                const response = await fetch('https://api.example.com/locations'); // Replace with your API endpoint
                const data = await response.json();
                setLocations(data);
            } catch (error) {
                console.error('Error fetching locations:', error);
            } finally {
                setIsLoading(false);
            }
        };

        fetchLocations();
    }, []);

    return (
        <div>
            <h1>Ohio Whiskey Tracker</h1>
            {isLoading ? (
                <p>Loading...</p>
            ) : (
                <>  
                    <MapComponent locations={locations} />
                    <LocationList locations={locations} />
                </>
            )}
        </div>
    );
};

export default App;