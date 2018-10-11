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
    self.ballSprite = BattleSprite('glball', 32, VIRTUAL_HEIGHT - 128)
    self.ballSprite.opacity = 0
end

function CatchState:enter(params)
    Timer.tween(1, {
        -- Vehicle's fuel is depleted as it moves from left to right
        [self.playerSprite] = { opacity = 0 },
        [self.ballSprite] = { opacity = 255 }
    }):finish(function()
        self:catch(self.opponentPokemon, function()
            self:fadeOutWhite()
        end)
    end)
end

function CatchState:catch(pokemon, onEnd)

    -- glball at opponent pokemon origin
    Timer.tween(1, {
        [self.ballSprite] = { x = self.opponentSprite.x - (gTextures[self.opponentSprite.texture]:getHeight()/2), 
            y = self.opponentSprite.y - (gTextures[self.opponentSprite.texture]:getHeight()/2) },
    })
        :finish(
            function()
                -- pokemon sprite white and scaled
                self.opponentSprite.blinking = true
                Timer.tween(1.5, {
                    [self.opponentSprite] = { scaleFactor = 0.1 },
                })
                    :finish(
                        function()
                            -- glball down
                            self.opponentSprite.opacity = 0
                            Timer.tween(0.3, {
                                [self.ballSprite] = { x = self.opponentSprite.x, y = self.opponentSprite.y },
                            })
                                :finish(
                                    function()
                                        local y0 = self.ballSprite.y
                                        Timer.tween(0.2, {
                                            [self.ballSprite] = {y = y0 - 10},
                                        })
                                            :finish(
                                                function()
                                                    local y0 = self.ballSprite.y
                                                    Timer.tween(0.2, {
                                                        [self.ballSprite] = {y = y0 + 10},
                                                    })
                                                        :finish(
                                                            -- catch function
                                                            function()
                                                                local remainingHPPercentage = pokemon.currentHP / pokemon.HP
                                                                local minHPBool = remainingHPPercentage <= 0.15

                                                                local catchRate = 75

                                                                -- increase the catch rate along the level
                                                                catchRate = catchRate + (pokemon.level * 2)

                                                                if minHPBool then
                                                                    local i = remainingHPPercentage
                                                                    while i > 0 do
                                                                        catchRate = catchRate + 1
                                                                        i = i - 0.01
                                                                    end
                                                                else
                                                                    catchRate = 0
                                                                end
                                                                
                                                                local random = math.random(100)

                                                                print(random, catchRate)
                                                                if random <= catchRate then
                                                                    self:success(pokemon, onEnd)
                                                                else
                                                                    self:failure(pokemon, onEnd)
                                                                end

                                                            end)
                                                end)
                                    end)
                        end)
            end)
end

function CatchState:success(pokemon, onEnd)
    Timer.after(0.5, function()
        gStateStack:pop()
        onEnd()
    end)
end

function CatchState:failure(pokemon, onEnd)
    Timer.after(0.5, function()
        gStateStack:pop()
        self.playerSprite:originalState()
        self.opponentSprite:originalState()
        gStateStack:push(BattleMenuState(self.battleState))
    end)
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

function CatchState:render()
    self.ballSprite:render()
end
