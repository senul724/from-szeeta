// ** Imports ** //

// * React * //
import React from "react";

const Card = ({ Name, Src, Alt, Func }) => {
  return (
    <div>
      <p>{Name}</p>
      <image src={Src} alt={Alt} />
      <button onClick={() => Func()}>Visit Event</button>
    </div>
  );
}


// ** Exports ** //
export { Card };

