

const Field = ({ Name, Type, setState, State, stateProp }) => {

  return (

    <div>
      <label>{` ${Name} `}</label>
      <input
        className="border border-slate-900 text-center"
        type={Type}
        onChange={
          (e) => {
            setState(
              prevState => ({
                ...prevState,
                [stateProp]: e.target.value,
              })
            )
          }
        }
      />
    </div>

  )

}

// ** Exports ** //
export { Field };

