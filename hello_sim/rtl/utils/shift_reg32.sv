`define SHIFT_REG_ARRAY_SIZE (5)
logic [31:0] shift_reg_array[`SHIFT_REG_ARRAY_SIZE];

function void SR32_shift(ref logic [31:0] array[`SHIFT_REG_ARRAY_SIZE],logic [31:0] new_value);
    int i;
    
    for(i=0;i<`SHIFT_REG_ARRAY_SIZE-1;i++)begin
        array[i]=array[i+1];
    end
    array[`SHIFT_REG_ARRAY_SIZE-1]=new_value;
endfunction

function int unsigned SR32_lastN(int n);
    int unsigned sum;
    int i;
    
    for(i=0;i<n;i++)begin
        sum+=shift_reg_array[`SHIFT_REG_ARRAY_SIZE-i-1];
    end
    SR32_lastN=sum;
endfunction
/*
function void test_inner(int abc[]);
endfunction

function void test2();
    int jjj[4];

    test_inner(jjj);
endfunction
*/
