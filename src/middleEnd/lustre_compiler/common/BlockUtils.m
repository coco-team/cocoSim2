classdef BlockUtils
    %BLOCKUTILS 
    
    properties (Constant)
        sat_dyn_ref = sprintf('Saturation Dynamic');
		zero_pole_ref = sprintf('DiscretizedZeroPole');
		zero_pole_discrete = sprintf('DiscreteZeroPole');
  

		compare_to_zero = sprintf('Compare To Zero');
		compare_to_constant = sprintf('Compare To Constant');

		detect_change = sprintf('Detect Change');
		detect_dec = sprintf('Detect Decrease');
		detect_inc = sprintf('Detect Increase');
		detect_rise_pos = sprintf('Detect Rise Positive');
		detect_rise_nonneg = sprintf('Detect Rise Nonnegative');
		detect_fall_neg = sprintf('Detect Fall Negative');
		detect_fall_nonpos = sprintf('Detect Fall Nonpositive');
        
        % props
		observer = 'Observer';
        assume = 'Assumptions'
        ensure = 'Ensures'
        
        %GAL_LIB constants
        sample = 0.2;
        integrator_sample = 0.2;
        clock_sample = 0.2;
        signal_builder_sample = 0.2;
        
		% Combinatorial block types (having rounding)
		SWITCH = 'Switch';
		GAIN = 'Gain';
		ABS = 'Abs';
		PRODUCT = 'Product';
		MINMAX = 'MinMax';
		DTI = 'DiscreteIntegrator';
		SUM = 'Sum';
		SATURATION = 'Saturate';
		MATH = 'Math';
		MULTIPORTSWITCH = 'MultiPortSwitch';
		SWITCHCASE = 'SwitchCase';
		IF = 'If';
		ASSIGNMENT = 'Assignment';
		SELECTOR = 'Selector';
		DT_CONV = 'DataTypeConversion';
		DISCRETE_FILTER = 'DiscreteFilter';
		LOOKUP_ND_DIRECT = 'LookupNDDirect';
        IMPLIES = 'CoCoSim-Implies'

		ROUNDED_BLOCKS = {BlockUtils.SWITCH, BlockUtils.GAIN, BlockUtils.ABS, BlockUtils.PRODUCT, BlockUtils.MINMAX, BlockUtils.DTI, BlockUtils.SUM, BlockUtils.SATURATION, BlockUtils.MATH, BlockUtils.MULTIPORTSWITCH, BlockUtils.DT_CONV, BlockUtils.DISCRETE_FILTER};

		ZERO_ROUNDED_BLOCKS = {BlockUtils.SWITCHCASE, BlockUtils.ASSIGNMENT,...
            BlockUtils.SELECTOR, BlockUtils.DT_CONV, BlockUtils.LOOKUP_ND_DIRECT, ...
            'MultiPortSwitch'};

		REF_MASKS = {BlockUtils.sat_dyn_ref, BlockUtils.zero_pole_ref, ...
            BlockUtils.compare_to_zero, BlockUtils.compare_to_constant, ...
            BlockUtils.IMPLIES};

		PROPERTY_BLOCKS = {BlockUtils.observer};
        
        ASSUME_BLOCKS = {BlockUtils.assume};
        
        ENSURE_BLOCKS = {BlockUtils.ensure};

		COMPARETO_BLOCKS = {BlockUtils.compare_to_zero, BlockUtils.compare_to_constant};

		DETECT_BLOCKS = {BlockUtils.detect_change, BlockUtils.detect_dec, BlockUtils.detect_inc, BlockUtils.detect_rise_pos, BlockUtils.detect_rise_nonneg, BlockUtils.detect_fall_neg, BlockUtils.detect_fall_nonpos};

		ACTION_BLOCKS = {BlockUtils.SWITCHCASE, BlockUtils.IF};

		% Variable names constants
		FOR_ITER = '_for_iter';
		FOR_ITER_RESET = '_foriter_reset';
		ACTION_RESET = '_action_reset';
		ENABLE_RESET = '_enable_reset';
        
        
        % Bus-Capable blocks with InputSignals parameter
        BUS_SELECTOR = 'BusSelector';
        BUS_ASSIGNMENT = 'BusAssignment';
        
        INPUT_SIGNALS_BUS_BLOCKS = {BlockUtils.BUS_SELECTOR, BlockUtils.BUS_ASSIGNMENT};
    end
    
    methods (Static = true)
        function [res] = is_ref_mask(name)
			res = ismember(name, BlockUtils.REF_MASKS);
		end
		function [res] = is_property(name)
			res = ismember(name, BlockUtils.PROPERTY_BLOCKS);
        end
        function [res] = is_assume(name)
			res = ismember(name, BlockUtils.ASSUME_BLOCKS);
        end
        function [res] = is_ensure(name)
			res = ismember(name, BlockUtils.ENSURE_BLOCKS);
		end
		function [res] = isCompareToMask(mask_type)
			res = ismember(mask_type, BlockUtils.COMPARETO_BLOCKS);
		end
		function [res] = isDetectMask(mask_type)
			res = ismember(mask_type, BlockUtils.DETECT_BLOCKS);
		end
		function [res] = is_action_block(type)
			res = ismember(type, BlockUtils.ACTION_BLOCKS);
		end
		function [res] = has_rounding(type)
			res = ismember(type, BlockUtils.ROUNDED_BLOCKS);
		end
		function [res] = needs_zero_rounding(type)
			res = ismember(type, BlockUtils.ZERO_ROUNDED_BLOCKS);
        end
        function [res] = is_input_signal_bus_block(type)
            res = ismember(type, BlockUtils.INPUT_SIGNALS_BUS_BLOCKS);
        end
    end
    
end

