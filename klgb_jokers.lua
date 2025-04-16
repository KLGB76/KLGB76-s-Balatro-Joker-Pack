--- STEAMODDED HEADER
--- MOD_NAME: KLGB76's Jokers Pack
--- MOD_ID: klgb-jokers
--- MOD_AUTHOR: [KLGB76]
--- MOD_DESCRIPTION: A pack with a bunch of jokers imagined and created by KLGB76
--- PREFIX: klgb-jp
--- VERSION: 2.0.0
----------------------------------------------
------------MOD CODE -------------------------

-- Sprites and sounds setup

SMODS.Atlas{
    key = 'Jokers', --atlas key
    path = 'Jokers.png', --atlas' path in (yourMod)/assets/1x or (yourMod)/assets/2x
    px = 71, --width of one card
    py = 95 -- height of one card
}

SMODS.Sound{
    key = 'truckfx',
    path = {
    ['default'] = 'truckfx.ogg'
    }
}

SMODS.Sound{
    key = 'jackpotfx',
    path = {
    ['default'] = 'jackpotfx.ogg'
    }
}

-- Jokers code

-- Truck-kun
SMODS.Joker{
    key = 'truck', --joker key
    loc_txt = { -- local text
        name = 'Truck-kun',
        text = {
          '{s:0.7}{C:inactive}(Must have room for {C:attention}Joker{}{C:inactive} and at least 1 card held in hand){}',
          'At the end of round',
          'Destroy a random card held in hand',
          'Create a random non-legendary {C:attention}Joker{}'
        },
        --[[unlock = {
            'Be {C:legendary}cool{}',
        }]]
    },
    atlas = 'Jokers', --atlas' key
    rarity = 1, --rarity: 1 = Common, 2 = Uncommon, 3 = Rare, 4 = Legendary
    --soul_pos = { x = 0, y = 0 },
    cost = 6, --cost to buy
    unlocked = true, --where it is unlocked or not: if true, 
    discovered = true, --whether or not it starts discovered
    blueprint_compat = true, --can it be blueprinted/brainstormed/other
    eternal_compat = true, --can it be eternal
    perishable_compat = true, --can it be perishable
    pos = {x = 0, y = 0}, --position in atlas, starts at 0, scales by the atlas' card size (px and py): {x = 1, y = 0} would mean the sprite is 71 pixels to the right

    calculate = function(self, card, context)
        if context.end_of_round and not context.game_over and context.cardarea ~= G.hand and #G.hand.cards > 0 and not card.debuff then
            local jokers_to_create = math.min(1, G.jokers.config.card_limit - (#G.jokers.cards + G.GAME.joker_buffer))
            G.GAME.joker_buffer = G.GAME.joker_buffer + jokers_to_create
            G.E_MANAGER:add_event(Event({
                func = function()
                    local destroyed_cards = {}
                    for i = 1, jokers_to_create do
                        play_sound('klgb-jp_truckfx')
                        destroyed_cards[#destroyed_cards+1] = pseudorandom_element(G.hand.cards, pseudoseed('random_destroy'))
                        for j=#destroyed_cards, 1, -1 do
                            local dead_card = destroyed_cards[j]
                            if dead_card.ability.name == 'Glass Card' then 
                                dead_card:shatter()
                            else
                                dead_card:start_dissolve(nil, j ~= #destroyed_cards)
                            end
                        end

                        local joker_card = create_card('Joker', G.jokers, nil, nil, nil, nil, nil, 'tru')
                        joker_card:add_to_deck()
                        G.jokers:emplace(joker_card)
                        joker_card:start_materialize()
                        G.GAME.joker_buffer = 0
                    end
                    return true
                end
            }))
            if jokers_to_create > 0 then
                return {message = "Isekai'd",}
            end
        end
    end,
}

-- The Keeper
SMODS.Joker{
    key = 'keeper', --joker key
    loc_txt = { -- local text
        name = 'The Keeper',
        text = {
          '{C:chips}+10{} Chips for',
          'each card held in hand'
        },
    },
    atlas = 'Jokers', --atlas' key
    rarity = 1, --rarity: 1 = Common, 2 = Uncommon, 3 = Rare, 4 = Legendary
    --soul_pos = { x = 0, y = 0 },
    cost = 5, --cost to buy
    unlocked = true, --where it is unlocked or not: if true, 
    discovered = true, --whether or not it starts discovered
    blueprint_compat = true, --can it be blueprinted/brainstormed/other
    eternal_compat = true, --can it be eternal
    perishable_compat = true, --can it be perishable
    pos = {x = 1, y = 0}, --position in atlas, starts at 0, scales by the atlas' card size (px and py): {x = 1, y = 0} would mean the sprite is 71 pixels to the right

    config = { 
        extra = {
          AddChips = 10 --configurable value
        }
      },

    calculate = function(self, card, context)
        if context.before and not card.debuff then
            card.ability.extra.AddChips = 10*#G.hand.cards
        end
        if context.joker_main and card.ability.extra.AddChips > 0 and not card.debuff then
            return {
                chip_mod = card.ability.extra.AddChips,
                message = localize { type = 'variable', key = 'a_chips', vars = { card.ability.extra.AddChips } }
            }
        end
    end,
}

-- Infinity Eight
SMODS.Joker{
    key = 'infinity', --joker key
    loc_txt = { -- local text
        name = 'Infinity Eight',
        text = {
          'Removes enhancements from all played {C:attention}8{} when scored',
          'Adds a permanent copy of all played {C:attention}8{} to deck when scored'
        },
    },
    atlas = 'Jokers', --atlas' key
    rarity = 3, --rarity: 1 = Common, 2 = Uncommon, 3 = Rare, 4 = Legendary
    --soul_pos = { x = 0, y = 0 },
    cost = 8, --cost to buy
    unlocked = true, --where it is unlocked or not: if true, 
    discovered = true, --whether or not it starts discovered
    blueprint_compat = true, --can it be blueprinted/brainstormed/other
    eternal_compat = true, --can it be eternal
    perishable_compat = true, --can it be perishable
    pos = {x = 2, y = 0}, --position in atlas, starts at 0, scales by the atlas' card size (px and py): {x = 1, y = 0} would mean the sprite is 71 pixels to the right

    calculate = function(self, card, context)
        if context.before and not card.debuff then
            for k, v in ipairs(context.scoring_hand) do
                if v:get_id() == 8 and v.config.center ~= G.P_CENTERS.c_base and not v.debuff and not v.vampired then
                    v.vampired = true
                    v:set_ability(G.P_CENTERS.c_base, nil, true)
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            v.vampired = nil
                            return true
                        end
                    }))
                end
                if v:get_id() == 8 and not v.debuff then
                    local infinite_card = copy_card(v, nil, nil, G.playing_card)
                    infinite_card:add_to_deck()
                    G.deck.config.card_limit = G.deck.config.card_limit + 1
                    table.insert(G.playing_cards, infinite_card)
                    G.deck:emplace(infinite_card)
                    infinite_card.states.visible = nil
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            v:juice_up()
                            infinite_card:start_materialize()
                            return true
                        end
                    }))
                    card_eval_status_text(card, 'extra', nil, nil, nil, {message = "Cleansed & Cloned",})
                    SMODS.calculate_context({playing_card_added = true, cards = {infinite_card}})
                end
            end
        end
    end,
}

-- Jackpot
SMODS.Joker{
    key = 'jackpot', --joker key
    loc_txt = { -- local text
        name = 'Jackpot',
        text = {
          'Earn {C:money}$25{} if {C:attention}first hand{}',
          'contains three {C:attention}7{}'
        },
    },
    atlas = 'Jokers', --atlas' key
    rarity = 2, --rarity: 1 = Common, 2 = Uncommon, 3 = Rare, 4 = Legendary
    --soul_pos = { x = 0, y = 0 },
    cost = 7, --cost to buy
    unlocked = true, --where it is unlocked or not: if true, 
    discovered = true, --whether or not it starts discovered
    blueprint_compat = true, --can it be blueprinted/brainstormed/other
    eternal_compat = true, --can it be eternal
    perishable_compat = true, --can it be perishable
    pos = {x = 3, y = 0}, --position in atlas, starts at 0, scales by the atlas' card size (px and py): {x = 1, y = 0} would mean the sprite is 71 pixels to the right

    calculate = function(self, card, context)
        if context.cardarea == G.jokers then
            local eval = function() return (G.GAME.current_round.hands_played == 0 and not card.debuff) end
            juice_card_until(card, eval, true)
        end

        if context.before and next(context.poker_hands['Three of a Kind']) and G.GAME.current_round.hands_played == 0 and not card.debuff then
            local TOAK_Card = context.poker_hands['Three of a Kind'][1][1]
            if TOAK_Card:get_id() == 7 then
                play_sound('klgb-jp_jackpotfx')
                G.E_MANAGER:add_event(Event({
                    func = function()
                        ease_dollars(25)
                        card_eval_status_text(card, 'extra', nil, nil, nil, {message = "JACKPOT!", colour = G.C.MONEY})
                        return true
                    end
                }))
            end
        end
    end,
}

--Cheval de 3
SMODS.Joker{
    key = 'trojan', --joker key
    loc_txt = { -- local text
        name = 'Cheval de 3',
        text = {
          'If {C:attention}first hand{} of round is a single {C:attention}3{},',
          '{C:attention}destroy{} all cards in consumable area.',
          'This Joker gains {X:mult,C:white}X0.25{} Mult per card destroyed',
          '{s:0.7}{C:inactive}(Currently {X:mult,C:white}X#1#{}{C:inactive} Mult){}'
        },
    },
    atlas = 'Jokers', --atlas' key
    rarity = 2, --rarity: 1 = Common, 2 = Uncommon, 3 = Rare, 4 = Legendary
    --soul_pos = { x = 0, y = 0 },
    cost = 7, --cost to buy
    unlocked = true, --where it is unlocked or not: if true, 
    discovered = true, --whether or not it starts discovered
    blueprint_compat = true, --can it be blueprinted/brainstormed/other
    eternal_compat = true, --can it be eternal
    perishable_compat = false, --can it be perishable
    pos = {x = 4, y = 0}, --position in atlas, starts at 0, scales by the atlas' card size (px and py): {x = 1, y = 0} would mean the sprite is 71 pixels to the right
    config = { 
        extra = {
          Xmult = 1 --configurable value
        }
    },

    loc_vars = function(self,info_queue,center)
        return {vars = {center.ability.extra.Xmult}} --#1# is replaced with card.ability.extra.Xmult
    end,

    calculate = function(self, card, context)
        if context.cardarea == G.jokers and not context.blueprint then
            local eval = function() return (G.GAME.current_round.hands_played == 0 and #G.consumeables.cards > 0 and not card.debuff) end
            juice_card_until(card, eval, true)
        end

        if context.before and #context.full_hand == 1 and context.full_hand[1]:get_id() == 3 and not context.full_hand[1].debuff and G.GAME.current_round.hands_played == 0 and not card.debuff and not context.blueprint then
            if #G.consumeables.cards > 0 then
                card.ability.extra.Xmult = card.ability.extra.Xmult + #G.consumeables.cards * 0.25
                local all_consum = #G.consumeables.cards
                local destroyed_cards = {}
                    for i = 1, all_consum do
                        destroyed_cards[#destroyed_cards+1] = G.consumeables.cards[i]
                        for j=#destroyed_cards, 1, -1 do
                            local dead_card = destroyed_cards[j]
                            if dead_card.ability.name == 'Glass Card' then 
                                dead_card:shatter()
                            else
                                dead_card:start_dissolve(nil, j ~= #destroyed_cards)
                            end
                        end
                    end
            end
        end

        if context.joker_main and card.ability.extra.Xmult > 1 and not card.debuff then
            return {
                card = card,
                Xmult_mod = card.ability.extra.Xmult,
                message = 'X' .. card.ability.extra.Xmult .. ' Mult',
                colour = G.C.MULT
            }
        end
    end,
}

--Polycarbonate Joker [DISCONTINUED]

-- Medusa's Glare
SMODS.Joker{
    key = 'medusa', --joker key
    loc_txt = { -- local text
        name = "Medusa's Glare",
        text = {
          'Enhances non-scoring cards',
          'into {C:attention}Stone Card{}',
          "{C:chips}+50{} Chips for each transformed card"
        },
    },
    atlas = 'Jokers', --atlas' key
    rarity = 3, --rarity: 1 = Common, 2 = Uncommon, 3 = Rare, 4 = Legendary
    --soul_pos = { x = 0, y = 0 },
    cost = 10, --cost to buy
    unlocked = true, --where it is unlocked or not: if true, 
    discovered = true, --whether or not it starts discovered
    blueprint_compat = false, --can it be blueprinted/brainstormed/other
    eternal_compat = true, --can it be eternal
    perishable_compat = true, --can it be perishable
    pos = {x = 1, y = 1}, --position in atlas, starts at 0, scales by the atlas' card size (px and py): {x = 1, y = 0} would mean the sprite is 71 pixels to the right

    config = { 
        extra = {
          AddChips = 0 --configurable value
        }
    },

    loc_vars = function(self,info_queue,center)
        info_queue[#info_queue+1] = G.P_CENTERS.m_stone --adds "Stone"'s description next to this card's description
    end,

    calculate = function(self, card, context)
        if context.before and not card.debuff then
            card.ability.extra.AddChips = 0
            for i=1, #context.full_hand do
                local card_is_scoring = false
                for j=1, #context.scoring_hand do
                    if context.full_hand[i] == context.scoring_hand[j] then
                        card_is_scoring = true
                    end
                end
                if card_is_scoring == false and not context.full_hand[i].debuff and not context.full_hand[i].clown_destroying then
                    card.ability.extra.AddChips = card.ability.extra.AddChips + 50
                            context.full_hand[i]:flip();
                            context.full_hand[i]:set_ability(G.P_CENTERS.m_stone);
                            context.full_hand[i]:flip();
                end
            end
        end

        if context.joker_main and card.ability.extra.AddChips > 0 and not card.debuff then
            return {
                chip_mod = card.ability.extra.AddChips,
                message = localize { type = 'variable', key = 'a_chips', vars = { card.ability.extra.AddChips } }
            }
        end
    end,
}

-- Metronome (aka Coding Hell)
SMODS.Joker{
    key = 'metronome', --joker key
    loc_txt = { -- local text
        name = 'Metronome',
        text = {
          "Randomizes played cards' rank when scored",
          "{s:0.7}{C:inactive}(Doesn't affect poker hand){}"
        },
    },
    atlas = 'Jokers', --atlas' key
    rarity = 1, --rarity: 1 = Common, 2 = Uncommon, 3 = Rare, 4 = Legendary
    --soul_pos = { x = 0, y = 0 },
    cost = math.random(1, 4), --cost to buy
    unlocked = true, --where it is unlocked or not: if true, 
    discovered = true, --whether or not it starts discovered
    blueprint_compat = false, --can it be blueprinted/brainstormed/other
    eternal_compat = true, --can it be eternal
    perishable_compat = true, --can it be perishable
    pos = {x = 0, y = 1}, --position in atlas, starts at 0, scales by the atlas' card size (px and py): {x = 1, y = 0} would mean the sprite is 71 pixels to the right

    calculate = function(self, card, context)
        if context.before and not card.debuff then
            local old_ranks = {}
            local new_ranks = {}
            local ordered_ranks = {}
            local new_cards = {}
            local has_stone = false
            local last_was_stone = false
            local stone_is_first = false

            for i = 1, #context.scoring_hand do --flips cards
                local percent = 1.15 - (i-0.999)/(#context.scoring_hand-0.998)*0.3
                context.scoring_hand[i]:flip();
                play_sound('card1', percent);
                context.scoring_hand[i]:juice_up(0.3, 0.3);
            end
            delay(0.2)

            if next(context.poker_hands["Five of a Kind"]) then --Case of 5OAK and Flush 5
                local foak_rank = pseudorandom_element({'2','3','4','5','6','7','8','9','T','J','Q','K','A'}, pseudoseed('metrofive'))
                for f = 1, #context.scoring_hand do
                    local card = context.scoring_hand[f]
                    local suit_prefix = string.sub(card.base.suit, 1, 1)..'_'
                    local rank_suffix = foak_rank
                    card:set_base(G.P_CARDS[suit_prefix..rank_suffix])
                end
            elseif next(context.poker_hands["Straight"]) then --Case of Straight and Straight Flush
                local s_rank = 0
                if #context.scoring_hand == 4 then
                    s_rank = pseudorandom_element({4,5,6,7,8,9,10,11,12,13,14}, pseudoseed('metrostraight'))
                elseif #context.scoring_hand == 5 then
                    s_rank = pseudorandom_element({5,6,7,8,9,10,11,12,13,14}, pseudoseed('metrostraight'))
                end
                for s=1, #context.scoring_hand do
                    if context.scoring_hand[s].config.center_key ~= 'm_stone' then
                        if #new_ranks == 0 then
                            local card = context.scoring_hand[s]
                            local suit_prefix = string.sub(card.base.suit, 1, 1)..'_'
                            local rank_suffix = s_rank
                            new_ranks[s] = rank_suffix
                            if rank_suffix < 10 then rank_suffix = tostring(rank_suffix)
                            elseif rank_suffix == 10 then rank_suffix = 'T'
                            elseif rank_suffix == 11 then rank_suffix = 'J'
                            elseif rank_suffix == 12 then rank_suffix = 'Q'
                            elseif rank_suffix == 13 then rank_suffix = 'K'
                            elseif rank_suffix == 14 then rank_suffix = 'A'
                            end
                            card:set_base(G.P_CARDS[suit_prefix..rank_suffix])
                        else
                            local card = context.scoring_hand[s]
                            local suit_prefix = string.sub(card.base.suit, 1, 1)..'_'
                            local rank_suffix = 0
                            if last_was_stone == true and stone_is_first == false then
                                rank_suffix = new_ranks[s-2] - 1
                            else
                                rank_suffix = new_ranks[s-1] - 1
                            end
                            if rank_suffix == 1 then
                                new_ranks[s] = 14
                            else
                                new_ranks[s] = rank_suffix
                            end
                            if rank_suffix < 10 and not rank_suffix == 1 then rank_suffix = tostring(rank_suffix)
                            elseif rank_suffix == 10 then rank_suffix = 'T'
                            elseif rank_suffix == 11 then rank_suffix = 'J'
                            elseif rank_suffix == 12 then rank_suffix = 'Q'
                            elseif rank_suffix == 13 then rank_suffix = 'K'
                            elseif rank_suffix == 1 then rank_suffix = 'A'
                            end
                            card:set_base(G.P_CARDS[suit_prefix..rank_suffix])
                        end
                        last_was_stone = false
                    else
                        has_stone = true
                        last_was_stone = true
                        if s==1 then stone_is_first=true end
                    end
                end
            elseif next(context.poker_hands["Flush"]) and next(context.poker_hands["Full House"]) then --Case of Flush House
                for p=1, #context.scoring_hand do --Randomization
                    local need_randomization = true
                    if context.scoring_hand[p].config.center_key ~= 'm_stone' then
                        if #old_ranks > 0 then
                            for o = 1, #old_ranks do
                                if context.scoring_hand[p]:get_id() == old_ranks[o] then
                                    local p_rank = new_ranks[o]
                                    local card = context.scoring_hand[p]
                                    old_ranks[p] = card:get_id()
                                    local suit_prefix = string.sub(card.base.suit, 1, 1)..'_'
                                    local rank_suffix = p_rank
                                    new_ranks[p] = rank_suffix
                                    if rank_suffix < 10 then rank_suffix = tostring(rank_suffix)
                                        elseif rank_suffix == 10 then rank_suffix = 'T'
                                        elseif rank_suffix == 11 then rank_suffix = 'J'
                                        elseif rank_suffix == 12 then rank_suffix = 'Q'
                                        elseif rank_suffix == 13 then rank_suffix = 'K'
                                        elseif rank_suffix == 14 then rank_suffix = 'A'
                                    end
                                    card:set_base(G.P_CARDS[suit_prefix..rank_suffix])
                                    new_cards[p] = card
                                    need_randomization = false
                                    break
                                end
                            end
                        end
                        if need_randomization == true then
                            local p_rank = pseudorandom_element({2,3,4,5,6,7,8,9,10,11,12,13,14}, pseudoseed('metropair'))
                            local card = context.scoring_hand[p]
                            old_ranks[p] = card:get_id()
                            local suit_prefix = string.sub(card.base.suit, 1, 1)..'_'
                            local rank_suffix = p_rank
                            new_ranks[p] = rank_suffix
                            if rank_suffix < 10 then rank_suffix = tostring(rank_suffix)
                                elseif rank_suffix == 10 then rank_suffix = 'T'
                                elseif rank_suffix == 11 then rank_suffix = 'J'
                                elseif rank_suffix == 12 then rank_suffix = 'Q'
                                elseif rank_suffix == 13 then rank_suffix = 'K'
                                elseif rank_suffix == 14 then rank_suffix = 'A'
                            end
                            card:set_base(G.P_CARDS[suit_prefix..rank_suffix])
                            new_cards[p] = card
                        end
                        last_was_stone = false
                    else
                        has_stone = true
                        last_was_stone = true
                        if p==1 then stone_is_first=true end
                    end
                end
            elseif next(context.poker_hands["Flush"]) and not next(context.poker_hands["Full House"]) and not next(context.poker_hands["Four of a Kind"]) and not next(context.poker_hands["Straight"]) and not next(context.poker_hands["Five of a Kind"]) then
                -- Case of Flush
                for fl=1, #context.scoring_hand do --Flush Randomization
                    if context.scoring_hand[fl].config.center_key ~= 'm_stone' then
                        local fl_rank = pseudorandom_element({2,3,4,5,6,7,8,9,10,11,12,13,14}, pseudoseed('metroflush'))
                        local card = context.scoring_hand[fl]
                        local suit_prefix = string.sub(card.base.suit, 1, 1)..'_'
                        local rank_suffix = fl_rank
                        new_ranks[fl] = rank_suffix
                        if rank_suffix < 10 then rank_suffix = tostring(rank_suffix)
                            elseif rank_suffix == 10 then rank_suffix = 'T'
                            elseif rank_suffix == 11 then rank_suffix = 'J'
                            elseif rank_suffix == 12 then rank_suffix = 'Q'
                            elseif rank_suffix == 13 then rank_suffix = 'K'
                            elseif rank_suffix == 14 then rank_suffix = 'A'
                        end
                        card:set_base(G.P_CARDS[suit_prefix..rank_suffix])
                        new_cards[fl] = card
                        last_was_stone = false
                    else
                        has_stone = true
                        last_was_stone = true
                        if fl==1 then stone_is_first=true end
                    end
                end
            elseif (next(context.poker_hands["Pair"]) and not next(context.poker_hands["Flush"]) and not next(context.poker_hands["Straight"]) and not next(context.poker_hands["Five of a Kind"])) then
                -- Case of Pair/Two Pair/3OAK/Full House/4OAK
                for p=1, #context.scoring_hand do --PairETC Randomization
                    local need_randomization = true
                    if context.scoring_hand[p].config.center_key ~= 'm_stone' then
                        if #old_ranks > 0 then
                            for o = 1, #old_ranks do
                                if context.scoring_hand[p]:get_id() == old_ranks[o] then
                                    local p_rank = new_ranks[o]
                                    local card = context.scoring_hand[p]
                                    old_ranks[p] = card:get_id()
                                    local suit_prefix = string.sub(card.base.suit, 1, 1)..'_'
                                    local rank_suffix = p_rank
                                    new_ranks[p] = rank_suffix
                                    if rank_suffix < 10 then rank_suffix = tostring(rank_suffix)
                                        elseif rank_suffix == 10 then rank_suffix = 'T'
                                        elseif rank_suffix == 11 then rank_suffix = 'J'
                                        elseif rank_suffix == 12 then rank_suffix = 'Q'
                                        elseif rank_suffix == 13 then rank_suffix = 'K'
                                        elseif rank_suffix == 14 then rank_suffix = 'A'
                                    end
                                    card:set_base(G.P_CARDS[suit_prefix..rank_suffix])
                                    need_randomization = false
                                    break
                                end
                            end
                        end
                        if need_randomization == true then
                            local p_rank = pseudorandom_element({2,3,4,5,6,7,8,9,10,11,12,13,14}, pseudoseed('metropair'))
                            local card = context.scoring_hand[p]
                            old_ranks[p] = card:get_id()
                            local suit_prefix = string.sub(card.base.suit, 1, 1)..'_'
                            local rank_suffix = p_rank
                            new_ranks[p] = rank_suffix
                            if rank_suffix < 10 then rank_suffix = tostring(rank_suffix)
                                elseif rank_suffix == 10 then rank_suffix = 'T'
                                elseif rank_suffix == 11 then rank_suffix = 'J'
                                elseif rank_suffix == 12 then rank_suffix = 'Q'
                                elseif rank_suffix == 13 then rank_suffix = 'K'
                                elseif rank_suffix == 14 then rank_suffix = 'A'
                            end
                            card:set_base(G.P_CARDS[suit_prefix..rank_suffix])
                        end
                        last_was_stone = false
                    else
                        has_stone = true
                        last_was_stone = true
                        if p==1 then stone_is_first=true end
                    end
                end
            else --Case of High Card
                for h=1, #context.scoring_hand do --High Card Randomization
                    if context.scoring_hand[h].config.center_key ~= 'm_stone' then
                        local h_rank = pseudorandom_element({2,3,4,5,6,7,8,9,10,11,12,13,14}, pseudoseed('metrohigh'))
                        local card = context.scoring_hand[h]
                        local suit_prefix = string.sub(card.base.suit, 1, 1)..'_'
                        local rank_suffix = h_rank
                        new_ranks[h] = rank_suffix
                        if rank_suffix < 10 then rank_suffix = tostring(rank_suffix)
                            elseif rank_suffix == 10 then rank_suffix = 'T'
                            elseif rank_suffix == 11 then rank_suffix = 'J'
                            elseif rank_suffix == 12 then rank_suffix = 'Q'
                            elseif rank_suffix == 13 then rank_suffix = 'K'
                            elseif rank_suffix == 14 then rank_suffix = 'A'
                        end
                        card:set_base(G.P_CARDS[suit_prefix..rank_suffix])
                        last_was_stone = false
                    else
                        has_stone = true
                        last_was_stone = true
                        if h==1 then stone_is_first=true end
                    end
                end
            end

            for i = 1, #context.scoring_hand do --unflips cards
                local percent = 0.85 + (i-0.999)/(#context.scoring_hand-0.998)*0.3
                context.scoring_hand[i]:flip();
                play_sound('tarot2', percent, 0.6);
                context.scoring_hand[i]:juice_up(0.3, 0.3);
            end
            delay(0.5)
        end
    end,
}

-- Four-Leaf Clover
SMODS.Joker{
    key = 'clover', --joker key
    loc_txt = { -- local text
        name = 'Four-Leaf Clover',
        text = {
          'All played cards with {C:clubs}Club{} suit',
          'become {C:attention}Lucky{} cards when scored'
        },
    },
    atlas = 'Jokers', --atlas' key
    rarity = 2, --rarity: 1 = Common, 2 = Uncommon, 3 = Rare, 4 = Legendary
    --soul_pos = { x = 0, y = 0 },
    cost = 7, --cost to buy
    unlocked = true, --where it is unlocked or not: if true, 
    discovered = true, --whether or not it starts discovered
    blueprint_compat = false, --can it be blueprinted/brainstormed/other
    eternal_compat = true, --can it be eternal
    perishable_compat = true, --can it be perishable
    pos = {x = 2, y = 1}, --position in atlas, starts at 0, scales by the atlas' card size (px and py): {x = 1, y = 0} would mean the sprite is 71 pixels to the right

    loc_vars = function(self,info_queue,center)
        info_queue[#info_queue+1] = G.P_CENTERS.m_lucky --adds "Lucky"'s description next to this card's description
    end,

    calculate = function(self, card, context)
        if context.before and not card.debuff then
            local luck = {}
                for k, v in ipairs(context.scoring_hand) do
                    if v:is_suit('Clubs', true) and not v.debuff then 
                        luck[#luck+1] = v
                        v:set_ability(G.P_CENTERS.m_lucky, nil, true)
                    end
                end
                if #luck > 0 then 
                    return {
                        message = "Good Luck",
                    }
                end
        end
    end,
}

-- Black Jack
SMODS.Joker{
    key = 'blackj', --joker key
    loc_txt = { -- local text
        name = 'Black Jack',
        text = {
          'All played Jacks become',
          '{C:attention}Negative{} cards when scored'
        },
    },
    atlas = 'Jokers', --atlas' key
    rarity = 2, --rarity: 1 = Common, 2 = Uncommon, 3 = Rare, 4 = Legendary
    --soul_pos = { x = 0, y = 0 },
    cost = 7, --cost to buy
    unlocked = true, --where it is unlocked or not: if true, 
    discovered = true, --whether or not it starts discovered
    blueprint_compat = false, --can it be blueprinted/brainstormed/other
    eternal_compat = true, --can it be eternal
    perishable_compat = true, --can it be perishable
    pos = {x = 3, y = 1}, --position in atlas, starts at 0, scales by the atlas' card size (px and py): {x = 1, y = 0} would mean the sprite is 71 pixels to the right

    loc_vars = function(self,info_queue,center)
        info_queue[#info_queue+1] = {key = 'e_negative_playing_card', set = 'Edition', config = {extra = 1}} --adds "Negative"'s description next to this card's description
    end,

    calculate = function(self, card, context)
        if context.before and not card.debuff then
            local jacks = {}
                for k, v in ipairs(context.scoring_hand) do
                    if v:get_id() == 11 and not v.debuff and not (v.edition and v.edition.key == 'e_negative') then 
                        jacks[#jacks+1] = v
                        v:set_edition('e_negative')
                    end
                end
                if #jacks > 0 then 
                    return {
                        message = "Darkened",
                    }
                end
        end
    end,
}

-- Anti-Joker
SMODS.Joker{
    key = 'anti', --joker key
    loc_txt = { -- local text
        name = 'Anti-Joker',
        text = {
          'Adds {X:mult,C:white}X0.5{} Mult for each',
          '{C:attention}Negative{} card you own',
          '{s:0.7}{C:inactive}(Currently {X:mult,C:white}X#1#{}{C:inactive} Mult){}'
        },
    },
    atlas = 'Jokers', --atlas' key
    rarity = 3, --rarity: 1 = Common, 2 = Uncommon, 3 = Rare, 4 = Legendary
    --soul_pos = { x = 0, y = 0 },
    cost = 8, --cost to buy
    unlocked = true, --where it is unlocked or not: if true, 
    discovered = true, --whether or not it starts discovered
    blueprint_compat = true, --can it be blueprinted/brainstormed/other
    eternal_compat = true, --can it be eternal
    perishable_compat = true, --can it be perishable
    pos = {x = 2, y = 2}, --position in atlas, starts at 0, scales by the atlas' card size (px and py): {x = 1, y = 0} would mean the sprite is 71 pixels to the right
    config = { 
        extra = {
          Xmult = 1 --configurable value
        }
    },

    loc_vars = function(self,info_queue,center)
        return {vars = {center.ability.extra.Xmult}} --#1# is replaced with card.ability.extra.Xmult
    end,

    calculate = function(self, card, context)
        if context.cardarea == G.jokers then
            card.ability.extra.Xmult = 1
            for k, v in pairs(G.playing_cards) do --Looks for Negative in Full Deck
                if v.edition and v.edition.key == 'e_negative' and not v.debuff then card.ability.extra.Xmult = card.ability.extra.Xmult + 0.5 end
            end
            for k, v in pairs(G.consumeables.cards) do --Looks for Negative in Consumable area
                if v.edition and v.edition.key == 'e_negative' and not v.debuff then card.ability.extra.Xmult = card.ability.extra.Xmult + 0.5 end
            end
            for k, v in pairs(G.jokers.cards) do --Looks for Negative in Jokers
                if v.edition and v.edition.key == 'e_negative' and not v.debuff then card.ability.extra.Xmult = card.ability.extra.Xmult + 0.5 end
            end
        end

        if context.joker_main and not card.debuff then
            if card.ability.extra.Xmult > 1 then
                return {
                    card = card,
                    Xmult_mod = card.ability.extra.Xmult,
                    message = 'X' .. card.ability.extra.Xmult .. ' Mult',
                    colour = G.C.MULT
                }
            end
        end
    end,
}

-- Clown Car
SMODS.Joker{
    key = 'car', --joker key
    loc_txt = { -- local text
        name = 'Clown Car',
        text = {
          "{s:0.7}{C:inactive}With no {C:attention}Driver's License{}{C:inactive}{}",
          '{C:attention}Destroy{} non-scoring cards',
          "{s:0.7}{C:inactive}With {C:attention}Driver's License{}{C:inactive}{}",
          'All played cards add {C:attention}double{} their',
          'rank to Mult when scored'
        },
    },
    atlas = 'Jokers', --atlas' key
    rarity = 2, --rarity: 1 = Common, 2 = Uncommon, 3 = Rare, 4 = Legendary
    --soul_pos = { x = 0, y = 0 },
    cost = 7, --cost to buy
    unlocked = true, --where it is unlocked or not: if true, 
    discovered = true, --whether or not it starts discovered
    blueprint_compat = false, --can it be blueprinted/brainstormed/other
    eternal_compat = true, --can it be eternal
    perishable_compat = true, --can it be perishable
    pos = {x = 4, y = 1}, --position in atlas, starts at 0, scales by the atlas' card size (px and py): {x = 1, y = 0} would mean the sprite is 71 pixels to the right
    config = { 
        extra = {
          has_license = false --configurable value
        }
    },
    
    loc_vars = function(self,info_queue,center)
        info_queue[#info_queue+1] = G.P_CENTERS.j_drivers_license --adds "Driver"'s description next to this card's description
    end,

    calculate = function(self, card, context)
        if context.cardarea == G.jokers then
            card.ability.extra.has_license = false
            if not card.debuff then
                for k, v in pairs(G.jokers.cards) do --Looks for Driver's License
                    if v.ability.name == "Driver's License" and not v.debuff then 
                        card.ability.extra.has_license = true
                        break
                    end
                end
            end
            
                local eval = function() return card.ability.extra.has_license == true end
                juice_card_until(card, eval, true)
        end

        if context.before and card.ability.extra.has_license == false and not card.debuff then
            for i=1, #context.full_hand do
                local card_is_scoring = false
                for j=1, #context.scoring_hand do
                    if context.full_hand[i] == context.scoring_hand[j] then
                        card_is_scoring = true
                    end
                end
                if card_is_scoring == false and not context.full_hand[i].debuff then
                    context.full_hand[i].clown_destroying = true
                    local dead_card = context.full_hand[i]
                    if dead_card.ability.name == 'Glass Card' then 
                        dead_card:shatter()
                    else
                        dead_card:start_dissolve()
                    end
                end
            end
        end

        if context.destroy_card and context.destroy_card.clown_destroying then
            return { remove = true }
        end

        if context.individual and not card.debuff then
            if context.cardarea == G.play and card.ability.extra.has_license == true then
                return {
                    mult = context.other_card.base.nominal * 2
                } 
            end
        end
    end,
}


-- Forbidden Summoning
SMODS.Joker{
    key = 'summon', --joker key
    loc_txt = { -- local text
        name = 'Forbidden Summoning',
        text = {
          "{s:0.7}{C:inactive}With no {C:attention}Séance{}{C:inactive}{}",
          '{C:green}#1# in 4{} chance to create a random',
          '{C:spectral}Spectral{} card when {C:attention}Blind{} is selected',
          '{s:0.7}{C:inactive}(Must have room){}',
          "{s:0.7}{C:inactive}With {C:attention}Séance{}{C:inactive}{}",
          'This Joker gains {X:mult,C:white}X1{} Mult',
          'per {C:spectral}Spectral{} card used this run',
          '{s:0.7}{C:inactive}(Currently {X:mult,C:white}X#2#{}{C:inactive} Mult){}'
        },
    },
    atlas = 'Jokers', --atlas' key
    rarity = 2, --rarity: 1 = Common, 2 = Uncommon, 3 = Rare, 4 = Legendary
    --soul_pos = { x = 0, y = 0 },
    cost = 7, --cost to buy
    unlocked = true, --where it is unlocked or not: if true, 
    discovered = true, --whether or not it starts discovered
    blueprint_compat = false, --can it be blueprinted/brainstormed/other
    eternal_compat = true, --can it be eternal
    perishable_compat = true, --can it be perishable
    pos = {x = 5, y = 1}, --position in atlas, starts at 0, scales by the atlas' card size (px and py): {x = 1, y = 0} would mean the sprite is 71 pixels to the right
    config = { 
        extra = {
          has_seance = false, --configurable value
          Xmult = 1
        }
    },
    
    loc_vars = function(self,info_queue,center)
        info_queue[#info_queue+1] = G.P_CENTERS.j_seance --adds "Séance"'s description next to this card's description
        return {vars = {G.GAME.probabilities.normal, center.ability.extra.Xmult}} --#1# is replaced with G.GAME.probabilities.normal and #2# is replaced with center.ability.extra.Xmult
    end,

    calculate = function(self, card, context)
        if context.cardarea == G.jokers then
            card.ability.extra.has_seance = false
            if not card.debuff then
                for k, v in pairs(G.jokers.cards) do --Looks for Séance
                    if v.ability.name == "Seance" and not v.debuff then 
                        card.ability.extra.has_seance = true
                        break
                    end
                end
            end
            
            local eval = function() return card.ability.extra.has_seance == true end
            juice_card_until(card, eval, true)

            if G.GAME.consumeable_usage_total and G.GAME.consumeable_usage_total.spectral > 0 then
                card.ability.extra.Xmult = 1 + G.GAME.consumeable_usage_total.spectral
            end
        end

        if context.setting_blind and card.ability.extra.has_seance == false and not card.getting_sliced and not card.debuff then
            if pseudorandom('summoning') < G.GAME.probabilities.normal/4 then
                if #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
                    G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
                    G.E_MANAGER:add_event(Event({
                        trigger = 'before',
                        delay = 0.0,
                        func = (function()
                                local card = create_card('Spectral',G.consumeables, nil, nil, nil, nil, nil, 'summon')
                                card:add_to_deck()
                                G.consumeables:emplace(card)
                                G.GAME.consumeable_buffer = 0
                            return true
                        end)}))
                    card_eval_status_text(context.blueprint_card or card, 'extra', nil, nil, nil, {message = localize('k_plus_spectral'), colour = G.C.SECONDARY_SET.Spectral})
                end
            end
        end

        if context.joker_main and card.ability.extra.Xmult > 1 and card.ability.extra.has_seance == true and not card.debuff then
            return {
                card = card,
                Xmult_mod = card.ability.extra.Xmult,
                message = 'X' .. card.ability.extra.Xmult .. ' Mult',
                colour = G.C.MULT
            }
        end
    end,
}

G.localization.descriptions.Other['my_edible'] = {
    name = 'Edible Joker',
    text = {
        'Gros Michel, Egg, Ice Cream,',
        'Cavendish, Turtle Bean, Diet Cola,',
        'Popcorn, Ramen, Seltzer'
    }
}

-- Restaurant Menu
SMODS.Joker{
    key = 'menu', --joker key
    loc_txt = { -- local text
        name = 'Restaurant Menu',
        text = {
          'Adds {X:mult,C:white}X1{} Mult for each',
          '{C:attention}Edible Joker{} you own',
          '{s:0.7}{C:inactive}(Currently {X:mult,C:white}X#1#{}{C:inactive} Mult){}'
        },
    },
    atlas = 'Jokers', --atlas' key
    rarity = 2, --rarity: 1 = Common, 2 = Uncommon, 3 = Rare, 4 = Legendary
    --soul_pos = { x = 0, y = 0 },
    cost = 6, --cost to buy
    unlocked = true, --where it is unlocked or not: if true, 
    discovered = true, --whether or not it starts discovered
    blueprint_compat = true, --can it be blueprinted/brainstormed/other
    eternal_compat = true, --can it be eternal
    perishable_compat = true, --can it be perishable
    pos = {x = 0, y = 2}, --position in atlas, starts at 0, scales by the atlas' card size (px and py): {x = 1, y = 0} would mean the sprite is 71 pixels to the right
    config = { 
        extra = {
          Xmult = 1, --configurable value
        }
    },

    loc_vars = function(self,info_queue,center)
        info_queue[#info_queue+1] = { set = 'Other', key = 'my_edible' } --adds "Edible"'s description next to this card's description
        return {vars = {center.ability.extra.Xmult}} --#1# is replaced with card.ability.extra.Xmult
    end,

    calculate = function(self, card, context)
        if context.cardarea == G.jokers then
            card.ability.extra.Xmult = 1
            for k, v in pairs(G.jokers.cards) do --Looks for food in Jokers
                if (v.ability.name == "Gros Michel" or v.ability.name == "Egg" or v.ability.name == "Ice Cream" or v.ability.name == "Cavendish" or v.ability.name == "Turtle Bean" or v.ability.name == "Popcorn" or v.ability.name == "Ramen" or v.ability.name == "Seltzer") and not v.debuff then
                    card.ability.extra.Xmult = card.ability.extra.Xmult + 1
                end
            end
        end

        if context.joker_main and not card.debuff then
            if card.ability.extra.Xmult > 1 then
                return {
                    card = card,
                    Xmult_mod = card.ability.extra.Xmult,
                    message = 'X' .. card.ability.extra.Xmult .. ' Mult',
                    colour = G.C.MULT
                }
            end
        end
    end,
}

-- Chicken
SMODS.Joker{
    key = 'chicken', --joker key
    loc_txt = { -- local text
        name = 'Chicken',
        text = {
            "{s:0.7}{C:inactive}If obtained before {C:attention}Egg{}{C:inactive}{}",
            'Every 3 rounds, create an {C:attention}Egg{}',
            'when {C:attention}Blind{} is selected',
            '{s:0.7}{C:inactive}(Must have room, #1# remaining){}',
            "{s:0.7}{C:inactive}If obtained after {C:attention}Egg{}{C:inactive}{}",
            'Adds double the sell value of all',
            'owned {C:attention}Egg{} to Mult',
            '{s:0.7}{C:inactive}(Currently {C:mult}+#2#{}{C:inactive} Mult){}'
        },
    },
    atlas = 'Jokers', --atlas' key
    rarity = 1, --rarity: 1 = Common, 2 = Uncommon, 3 = Rare, 4 = Legendary
    --soul_pos = { x = 0, y = 0 },
    cost = 4, --cost to buy
    unlocked = true, --where it is unlocked or not: if true, 
    discovered = true, --whether or not it starts discovered
    blueprint_compat = false, --can it be blueprinted/brainstormed/other
    eternal_compat = true, --can it be eternal
    perishable_compat = true, --can it be perishable
    pos = {x = 1, y = 2}, --position in atlas, starts at 0, scales by the atlas' card size (px and py): {x = 1, y = 0} would mean the sprite is 71 pixels to the right
    config = { 
        extra = {
            AddMult = 0, --configurable value
            laying = 0,
            chicken_first = true
        }
    },

    loc_vars = function(self,info_queue,center)
        info_queue[#info_queue+1] = G.P_CENTERS.j_egg --adds "Egg"'s description next to this card's description
        return {vars = {center.ability.extra.laying, center.ability.extra.AddMult}} --#1# is replaced with G.GAME.probabilities.normal and #2# is replaced with center.ability.extra.Xmult
    end,

    add_to_deck = function(self, card, from_debuff)
        card.ability.extra.chicken_first = true
        for k, v in pairs(G.jokers.cards) do --Looks for Egg
            if v.ability.name == "Egg" then 
                card.ability.extra.chicken_first = false
                break
            end
        end
    end,

    calculate = function(self, card, context)
        if context.cardarea == G.jokers then
            if not card.debuff then
                local eval = function() return card.ability.extra.chicken_first == false end
                juice_card_until(card, eval, true)
            end

            card.ability.extra.AddMult = 0
            for k, v in pairs(G.jokers.cards) do --Looks for food in Jokers
                if v.ability.name == "Egg" and not v.debuff then
                    card.ability.extra.AddMult = card.ability.extra.AddMult + (v.sell_cost * 2)
                end
            end
        end

        if context.setting_blind and card.ability.extra.chicken_first == true and not card.getting_sliced and not card.debuff then
            if card.ability.extra.laying == 0 then
                local jokers_to_create = math.min(1, G.jokers.config.card_limit - (#G.jokers.cards + G.GAME.joker_buffer))
                G.GAME.joker_buffer = G.GAME.joker_buffer + jokers_to_create
                for i = 1, jokers_to_create do
                    local joker_card = create_card('Joker', G.jokers, nil, nil, nil, nil, 'j_egg', 'chick')
                    joker_card:add_to_deck()
                    G.jokers:emplace(joker_card)
                    joker_card:start_materialize()
                    G.GAME.joker_buffer = 0
                end
                card.ability.extra.laying = 3
                if jokers_to_create > 0 then
                    return {message = "Egg Laid",}
                end
            else
                card.ability.extra.laying = card.ability.extra.laying - 1
            end
        end

        if context.joker_main and card.ability.extra.AddMult > 0 and card.ability.extra.chicken_first == false and not card.debuff then
            return {
                card = card,
                mult_mod = card.ability.extra.AddMult,
                message = '+' .. card.ability.extra.AddMult .. ' Mult',
                colour = G.C.MULT
            }
        end
    end,
}

-- The Conqueror
SMODS.Joker{
    key = 'conqueror', --joker key
    loc_txt = { -- local text
        name = 'The Conqueror',
        text = {
          'If {C:attention}first card{} in hand played',
          'is a {C:attention}scoring King{}, turn all',
          'other cards in that hand',
          'into the {C:attention}suit{} of that King',
          "{s:0.7}{C:inactive}(Doesn't affect poker hand){}"
        },
    },
    atlas = 'Jokers', --atlas' key
    rarity = 3, --rarity: 1 = Common, 2 = Uncommon, 3 = Rare, 4 = Legendary
    --soul_pos = { x = 0, y = 0 },
    cost = 10, --cost to buy
    unlocked = true, --where it is unlocked or not: if true, 
    discovered = true, --whether or not it starts discovered
    blueprint_compat = false, --can it be blueprinted/brainstormed/other
    eternal_compat = true, --can it be eternal
    perishable_compat = true, --can it be perishable
    pos = {x = 3, y = 2}, --position in atlas, starts at 0, scales by the atlas' card size (px and py): {x = 1, y = 0} would mean the sprite is 71 pixels to the right

    calculate = function(self, card, context)
        if context.before and not card.debuff then
            if (context.full_hand[1] == context.scoring_hand[1]) and (context.scoring_hand[1]:get_id() == 13) and not (context.scoring_hand[1].debuff) and not (#context.full_hand == 1) then
                local new_suit = string.sub(context.scoring_hand[1].base.suit, 1, 1)..'_'
                for i=2, #context.full_hand do
                    local card = context.full_hand[i]
                    local rank_suffix = context.full_hand[i]:get_id()
                    if rank_suffix < 10 then rank_suffix = tostring(rank_suffix)
                        elseif rank_suffix == 10 then rank_suffix = 'T'
                        elseif rank_suffix == 11 then rank_suffix = 'J'
                        elseif rank_suffix == 12 then rank_suffix = 'Q'
                        elseif rank_suffix == 13 then rank_suffix = 'K'
                        elseif rank_suffix == 14 then rank_suffix = 'A'
                    end
                    card:set_base(G.P_CARDS[new_suit..rank_suffix])
                end
            end
        end
    end,
}

-- The Anomaly [DISCONTINUED]

-- The Abductor [DISCONTINUED]

-- The Collector
SMODS.Joker{
    key = 'collector', --joker key
    loc_txt = { -- local text
        name = 'The Collector',
        text = {
          'This Joker gains {C:mult}+10{} Mult',
          'at the end of round',
          'Resets when any',
          '{C:attention}Booster Pack{} is opened',
          "{s:0.7}{C:inactive}(Currently {C:mult}+#1#{}{C:inactive} Mult){}"
        },
    },
    atlas = 'Jokers', --atlas' key
    rarity = 2, --rarity: 1 = Common, 2 = Uncommon, 3 = Rare, 4 = Legendary
    --soul_pos = { x = 0, y = 0 },
    cost = 6, --cost to buy
    unlocked = true, --where it is unlocked or not: if true, 
    discovered = true, --whether or not it starts discovered
    blueprint_compat = true, --can it be blueprinted/brainstormed/other
    eternal_compat = true, --can it be eternal
    perishable_compat = true, --can it be perishable
    pos = {x = 0, y = 3}, --position in atlas, starts at 0, scales by the atlas' card size (px and py): {x = 1, y = 0} would mean the sprite is 71 pixels to the right
    config = { 
        extra = {
            AddMult = 0, --configurable value
        }
    },

    loc_vars = function(self,info_queue,center)
        return {vars = {center.ability.extra.AddMult}}
    end,

    calculate = function(self, card, context)
        if context.joker_main and card.ability.extra.AddMult > 0 and not card.debuff then
            return {
                card = card,
                mult_mod = card.ability.extra.AddMult,
                message = '+' .. card.ability.extra.AddMult .. ' Mult',
                colour = G.C.MULT
            }
        end

        if context.end_of_round and context.main_eval and not context.blueprint then
            card.ability.extra.AddMult = card.ability.extra.AddMult + 10
            return {message = localize('k_upgrade_ex'),}
        end

        if context.open_booster and not context.blueprint then
            card.ability.extra.AddMult = 0
            return {message = localize('k_reset'),}
        end
    end,
}

-- Eclipse
SMODS.Joker{
    key = 'eclipse', --joker key
    loc_txt = { -- local text
        name = 'Eclipse',
        text = {
          'When {C:attention}The Sun{} is used,',
          'create {C:attention}The Moon{}',
          'When {C:attention}The Moon{} is used,',
          'create {C:attention}The Sun{}',
          '{s:0.7}{C:inactive}(Must have room){}',
          "{s:0.7}{C:inactive}(#1#){}"
        },
    },
    atlas = 'Jokers', --atlas' key
    rarity = 2, --rarity: 1 = Common, 2 = Uncommon, 3 = Rare, 4 = Legendary
    --soul_pos = { x = 0, y = 0 },
    cost = 6, --cost to buy
    unlocked = true, --where it is unlocked or not: if true, 
    discovered = true, --whether or not it starts discovered
    blueprint_compat = false, --can it be blueprinted/brainstormed/other
    eternal_compat = true, --can it be eternal
    perishable_compat = true, --can it be perishable
    pos = {x = 1, y = 3}, --position in atlas, starts at 0, scales by the atlas' card size (px and py): {x = 1, y = 0} would mean the sprite is 71 pixels to the right
    config = { 
        extra = {
            cards_to_discard = 0,
            active = true
        }
    },

    loc_vars = function(self,info_queue,center)
        info_queue[#info_queue+1] = G.P_CENTERS.c_sun
        info_queue[#info_queue+1] = G.P_CENTERS.c_moon
        if center.ability.extra.active == true then
            return {vars = {"Currently Active"}} 
        else
            return {vars = {'Recharges after ' .. center.ability.extra.cards_to_discard .. ' cards discarded.'}}
        end
    end,

    calculate = function(self, card, context)
        if card.ability.extra.active == true and context.using_consumeable and not card.debuff then
            if context.consumeable.ability.name == 'The Sun' then
                if #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
                    local eclipse_card = create_card('Tarot', G.consumeables, nil, nil, nil, nil, 'c_moon', 'eclipse')
                    eclipse_card:add_to_deck()
                    G.consumeables:emplace(eclipse_card)
                end

                card.ability.extra.cards_to_discard = 24
                card.ability.extra.active = false
            elseif context.consumeable.ability.name == 'The Moon' and #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
                if #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
                    local eclipse_card = create_card('Tarot', G.consumeables, nil, nil, nil, nil, 'c_sun', 'eclipse')
                    eclipse_card:add_to_deck()
                    G.consumeables:emplace(eclipse_card)
                end
                
                card.ability.extra.cards_to_discard = 24
                card.ability.extra.active = false
            end
        end

        if card.ability.extra.active == false and context.discard and not card.debuff then
            if card.ability.extra.cards_to_discard <= 1 then
                card.ability.extra.active = true
                return {message = "An eclipse is coming"}
            else
                card.ability.extra.cards_to_discard = card.ability.extra.cards_to_discard - 1
            end
        end
    end,
}

--[[ Known Bug(s):
- All cards randomized by Metronome get debuffed by The Pillar.
- The sound of cards being destroyed by Clown Car plays twice
]]
  
----------------------------------------------
------------MOD CODE END----------------------
    
