classdef bsParameters < parametersBase
    %BSPARAMETERS ：5G NR base station
    
    properties
%         location = [0,0,0];
        bsAntTxNum = 8;
        bsAntSensingRXNum = 8;
        bsAntCommTxNum = 8;
        txPower = 40;
    end
    
    methods
        function obj = bsParameters()
            %BSPARAMETERS 构造此类的实例
            %   此处显示详细说明
      
        end
        
        function outputArg = method1(obj,inputArg)
            %METHOD1 此处显示有关此方法的摘要
            %   此处显示详细说明
            outputArg = obj.Property1 + inputArg;
        end
    end
end

