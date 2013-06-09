class addr_hook;
    lastN_SumPeaceCnt m_cnt1;
    lastN_SumPeaceCnt m_cnt2;
    lastN_SumPeaceCnt m_cnt3;
    lastN_SumPeaceCnt m_cnt4;
    extern function new();
    extern function void hook(input logic[31:0] addr);
endclass

function addr_hook::new;
    m_cnt1=new (1);
    m_cnt2=new (2);
    m_cnt3=new (3);
    m_cnt4=new (4);
endfunction:new

function void addr_hook::hook(input logic[31:0] addr);
    SR32_shift(shift_reg_array,addr);
    do begin
        if(m_cnt1.updateAndChk())begin
            break;
        end
        if(m_cnt2.updateAndChk())begin
            break;
        end
        if(m_cnt3.updateAndChk())begin
            break;
        end
        if(m_cnt4.updateAndChk())begin
            break;
        end
        return;
    end while(0);
    $finish;
    return;
endfunction:hook;
