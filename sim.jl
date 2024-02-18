# Description: A simple 2-core processor simulator

include("execute_functions.jl")
using .ExecuteFunctions

mutable struct Core1
    registers::Array{Int,1}
    pc::Int
    program::Array{String,1}
    function Core1()
        this = new()
        this.registers = fill(0, 32)
        this.pc = 1
        this.program = []
        return this
    end
end

function core_Init()
    return Core1()
end

function execute(core::Core1, memory::Array{Int,1})
    if core.pc > length(core.program)
        return
    end
    ExecuteFunctions.execute(core.program[core.pc], core.registers, memory)
    core.pc += 1
end

mutable struct Processor
    memory::Array{Int,1}
    clock::Int
    cores::Array{Core1,1}
    function Processor()
        this = new()
        this.memory = fill(0, 4096)
        this.clock = 0
        this.cores = [core_Init(), core_Init()]
        return this
    end
end

function processor_Init()
    return Processor()
end

function run(processor::Processor)
    while processor.clock < maximum([length(core.program) for core in processor.cores])
        for i in 1:2
            if processor.clock < length(processor.cores[i].program)
                execute(processor.cores[i], processor.memory)
            end
        end
        processor.clock += 1
    end    
end

function main()
    sim = Processor()
    sim.cores[1].registers[2] = 8
    sim.cores[1].registers[3] = 10
    sim.cores[1].registers[5] = 5
    sim.memory[6] = 18
    for i in 1:length(sim.cores)
        println(sim.cores[i].registers)
    end

    sim.cores[1].program = ["add x1 x2 x3",
                            "ld x5 5",
                            "add x1 x1 x5",
                            "st x1 6"]
    sim.cores[2].program = ["add x1 x2 x3", "ld x5 5"]
    run(sim)
    for i in 1:length(sim.cores)
        println(sim.cores[i].registers)
    end
end

main()
