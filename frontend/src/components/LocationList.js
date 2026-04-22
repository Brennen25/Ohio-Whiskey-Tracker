import React from 'react';

const LocationList = ({ locations }) => {
    return (
        <div>
            <h1>OHLQ Locations</h1>
            <ul>
                {locations.map((location, index) => (
                    <li key={index}>
                        <strong>{location.name}</strong> - Release Date: {new Date(location.releaseDate).toLocaleString()}
                    </li>
                ))}
            </ul>
        </div>
    );
};

export default LocationList;