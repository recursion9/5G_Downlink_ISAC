classdef parametersBase
    %PARAMETERSBASE 此处显示有关此类的摘要
    %   此处显示详细说明
    
    properties
        location = [0,0,0];
    end
    
    methods
        function obj = parametersBase()
            %PARAMETERSBASE 构造此类的实例
            %   此处显示详细说明
        end
        
        function outputArg = method1(obj,inputArg)
            %METHOD1 此处显示有关此方法的摘要
            %   此处显示详细说明
            outputArg = obj.Property1 + inputArg;
        end
    end
end

