--[[
    GD50
    Pokemon

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

CatchState = Class{__includes = BaseState}

function CatchState:init(battleState)
    self.battleState = battleState
    self.playerPokemon = self.battleState.player.party.pokemon[1]
    self.opponentPokemon = self.battleState.opponent.party.pokemon[1]

    self.playerSprite = self.battleState.playerSprite
    self.opponentSprite = self.battleState.opponentSprite
end

function CatchState:enter(params)
    self:attack(self.firstPokemon, self.secondPokemon, self.firstSprite, self.secondSprite, self.firstBar, self.secondBar,

    function()

        -- remove the message
        gStateStack:pop()

        -- check to see whether the player or enemy died
        if self:checkDeaths() then
            gStateStack:pop()
            return
        end

        self:attack(self.secondPokemon, self.firstPokemon, self.secondSprite, self.firstSprite, self.secondBar, self.firstBar,
    
        function()

            -- remove the message
            gStateStack:pop()

            -- check to see whether the player or enemy died
            if self:checkDeaths() then 
                gStateStack:pop()
                return
            end

            -- remove the last attack state from the stack
            gStateStack:pop()
            gStateStack:push(BattleMenuState(self.battleState))
        end)
    end)
end

function CatchState:catchTry(opponentPokemon, player, onEnd)

end

function CatchState:success()

end

function CatchState:failure()

end

function CatchState:fadeOutWhite()
    -- fade in
    gStateStack:push(FadeInState({
        r = 255, g = 255, b = 255
    }, 1, 
    function()
        -- resume field music
        gSounds['victory-music']:stop()
        gSounds['field-music']:play()
        
        -- pop off the battle state
        gStateStack:pop()
        gStateStack:push(FadeOutState({
            r = 255, g = 255, b = 255
        }, 1, function() end))
    end))
end