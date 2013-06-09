class lastN_SumPeaceCnt;
//    ref logic [31:0] array[`SHIFT_REG_ARRAY_SIZE];
    int m_lastN;
    int unsigned m_sum;
    int unsigned m_peaceCnt;
    extern function new(int lastN);
    extern function int updateAndChk();
endclass

function lastN_SumPeaceCnt::new(int lastN);
    this.m_lastN=lastN;
    this.m_sum=0;
    this.m_peaceCnt=0;
endfunction:new

function int lastN_SumPeaceCnt::updateAndChk();
    int unsigned sum;

    sum=SR32_lastN(m_lastN);
    if(m_sum==sum)begin
        ++m_peaceCnt;
    end else begin
        m_sum=sum;
        m_peaceCnt=1;
    end
    if(m_peaceCnt>30)begin
        return -1;
    end else begin
        return 0;
    end
endfunction:updateAndChk
