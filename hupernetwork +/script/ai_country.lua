function CountryAI_Tick(country)
    -- Verifica si el país tiene suficientes recursos para reclutar las unidades necesarias
    if country:GetResource("money") >= 3000 then
        -- Verifica si el país está siendo justificado o tiene objetivo de guerra
        if country:IsBeingJustified() or country:HasWarGoal() then
            country:Mobilize()
        end
        
        -- Función para crear brigadas profesionales según el tipo de unidad y la cantidad requerida
        local function createBrigades(unitType, requiredBrigades)
            local currentBrigades = army:GetNumberOfRegimentsOfType(unitType)
            local brigadesToCreate = requiredBrigades - currentBrigades
            
            if brigadesToCreate > 0 then
                -- Crear brigadas profesionales
                for i = 1, brigadesToCreate do
                    country:BuildProfessionalRegiment(unitType)
                end
                
                -- Dividir el ejército en las brigadas recién creadas
                local unitsToCreate = brigadesToCreate * 30
                country:SplitArmy(army, unitType, unitsToCreate)
            end
        end

        -- Crea brigadas de infantería
        createBrigades("infantry", 4)

        -- Crea brigadas de caballería
        createBrigades("cuirassier", 1)

        -- Crea brigadas de artillería
        createBrigades("artillery", 5)

        -- Mover ejército a provincias aleatorias para proteger las fronteras
        local provinces = country:GetProvinces()
        local borderProvinces = {}
        for i = 1, #provinces do
            local province = provinces[i]
            if province:IsAdjacentToEnemy() then
                table.insert(borderProvinces, province)
            end
        end

        if #borderProvinces > 0 then
            -- Si hay provincias fronterizas, mueve el ejército a una de ellas
            local randomProvinceIndex = math.random(1, #borderProvinces)
            local targetProvince = borderProvinces[randomProvinceIndex]
            country:MoveArmy(army, targetProvince:GetPosition())
        else
            -- Si no hay provincias fronterizas, mueve el ejército a una provincia aleatoria
            local randomProvinceIndex = math.random(1, #provinces)
            local targetProvince = provinces[randomProvinceIndex]
            country:MoveArmy(army, targetProvince:GetPosition())
        end
    end
end     


function CountryAI_Tick(country)
    -- Verifica si el país tiene suficientes recursos para construir fábricas
    if country:GetResource("money") >= 5000 then
        -- Lista de todos los recursos que las fábricas pueden producir
        local factoryProduceResources = {
            "ammunition", "small_arms", "artillery", "canned_food", "cement", "electric_gear",
            "fabric", "fertilizer", "glass", "liquor", "luxury_clothes", "luxury_furniture",
            "machine_parts", "paper", "regular_clothes", "regular_furniture", "steel",
            "telephones", "tanks", "automobiles", "airplanes", "electricity", "parts", "radio"
        }

        -- Construye fábricas para los recursos que las fábricas pueden producir
        for i = 1, #factoryProduceResources do
            local resource = factoryProduceResources[i]
            if country:GetResource(resource) <= 0 then
                country:BuildFactory(resource)
            end
        end

        -- Mejora las fábricas existentes
        local factories = country:GetFactories()
        for i = 1, #factories do
            local factory = factories[i]
            -- Si la fábrica no está en construcción y hay suficiente dinero, mejórala
            if not factory:IsBuilding() and country:GetResource("money") >= 5000 then
                factory:Improve()
            end
        end
    end

    -- Reduce el stockpile si es necesario
    local stockpileThreshold = 1000
    for i = 1, #factoryProduceResources do
        local resource = factoryProduceResources[i]
        local stockpile = country:GetResource(resource .. "_stockpile")
        if stockpile > stockpileThreshold then
            country:SetResource(resource .. "_stockpile", stockpile - stockpileThreshold)
        end
    end
end

function OnProvinceCaptured(province)
    -- No destruir fábricas al capturar provincias
end


function CountryAI_Tick(country)
    -- Verifica si el país tiene suficientes recursos para construir barcos
    if country:GetResource("money") >= 5000 then
        -- Construye barcos de transporte si no hay suficientes
        local transportShipsNeeded = 10
        local transportShips = country:GetNumberOfShips("transport_ship")
        if transportShips < transportShipsNeeded then
            for i = 1, transportShipsNeeded - transportShips do
                country:BuildShip("transport_ship")
            end
        end

        -- Construye barcos de guerra si no hay suficientes
        local warShipsNeeded = 5
        local warShips = country:GetNumberOfShips("war_ship")
        if warShips < warShipsNeeded then
            for i = 1, warShipsNeeded - warShips do
                country:BuildShip("war_ship")
            end
        end

        -- Obtiene una lista de provincias costeras
        local coastalProvinces = country:GetCoastalProvinces()

        -- Selecciona una provincia costera aleatoria para realizar el desembarco
        local randomProvinceIndex = math.random(1, #coastalProvinces)
        local targetProvince = coastalProvinces[randomProvinceIndex]

        -- Mueve los barcos a la provincia seleccionada
        local transportShips = country:GetShips("transport_ship")
        for i = 1, #transportShips do
            local ship = transportShips[i]
            country:MoveShip(ship, targetProvince:GetPosition())
        end

        -- Mueve los barcos de guerra a la misma provincia
        local warShips = country:GetShips("war_ship")
        for i = 1, #warShips do
            local ship = warShips[i]
            country:MoveShip(ship, targetProvince:GetPosition())
        end
    end
end

function CountryAI_Tick(country)
    -- Verifica si el país tiene suficientes recursos para construir fortalezas y raíles
    if country:GetResource("money") >= 5000 then
        -- Construye fortalezas en las fronteras y provincias importantes si no hay suficientes
        local importantProvinces = country:GetImportantProvinces()
        for province in importantProvinces do
            if not province:HasFort() then
                country:BuildFort(province)
            end
        end

        -- Espera un tiempo antes de mejorar las fortalezas
        local fortUpgradeTime = 30 -- Espera 30 días antes de mejorar las fortalezas
        if country:GetDaysSinceLastFortUpgrade() >= fortUpgradeTime then
            local forts = country:GetForts()
            for i = 1, #forts do
                local fort = forts[i]
                if fort:GetLevel() < 5 then -- Mejora la fortaleza hasta el nivel máximo
                    fort:Upgrade()
                end
            end
        end

        -- Construye lentamente fortalezas y raíles en la capital
        local capital = country:GetCapital()
        if not capital:HasFort() then
            country:BuildFort(capital)
        elseif not capital:HasRailroad() then
            country:BuildRailroad(capital)
        end
    end

    -- Reduce el stockpile si es necesario
    local stockpileThreshold = 1000
    local allResources = country:GetAllResources()
    for i = 1, #allResources do
        local resource = allResources[i]
        local stockpile = country:GetResource(resource .. "_stockpile")
        if stockpile > stockpileThreshold then
            country:SetResource(resource .. "_stockpile", stockpile - stockpileThreshold)
        end
    end
end

function CountryAI_ManageEconomy(country)
    -- Verifica si la economía está en rojo
    if country:GetResource("money") < 0 then
        -- Cambia al gobierno que maximiza la capacidad de construcción de fábricas
        country:ChangeGovernment("interventionism")

        -- Aumenta los impuestos al máximo
        country:SetTaxRate(100)

        -- Reduce el gasto militar y de construcción
        country:SetMilitarySpending(50)
        country:SetConstructionSpending(50)
    end

    -- Verifica si la economía está en verde
    if country:GetResource("money") >= 0 then
        -- Aumenta el gasto militar y de construcción a la mitad
        country:SetMilitarySpending(100)
        country:SetConstructionSpending(100)

        -- Redefine los impuestos y las tarifas para mantener la economía en verde
        local profitMargin = 5000 -- Margen de ganancia deseado
        local money = country:GetResource("money")
        local taxRate = country:GetTaxRate()
        local tariff = country:GetTariff()

        while money < profitMargin do
            if money < 0 then
                -- Aumenta las tarifas
                country:SetTariff(tariff + 1)
            else
                -- Reduce los impuestos
                country:SetTaxRate(taxRate - 1)
            end
            money = country:GetResource("money")
        end
    end
end

function CountryAI_RushFormablesAndDecisions(country)
    -- Verifica si hay formables disponibles
    local formables = country:GetAvailableFormables()
    for i = 1, #formables do
        local formable = formables[i]
        -- Verifica si el formable está disponible para ser completado
        if country:CanCompleteFormable(formable) then
            country:CompleteFormable(formable)
        end
    end

    -- Verifica si hay decisiones disponibles
    local decisions = country:GetAvailableDecisions()
    for i = 1, #decisions do
        local decision = decisions[i]
        -- Verifica si la decisión está disponible para ser tomada
        if country:CanTakeDecision(decision) then
            country:TakeDecision(decision)
        end
    end

    -- Espera a los requisitos necesarios para los formables y decisiones
    local requiredStates = {
        "Moscow", "Saint Petersburg" -- Agrega aquí los nombres de los estados necesarios
    }
    for i = 1, #requiredStates do
        local stateName = requiredStates[i]
        local state = country:GetState(stateName)
        if not state:IsOwnedBy(country) then
            country:RequestStateOwnership(state)
        end
    end
end

function CountryAI_ManageExpansion(country)
    -- Verifica si hay guerras en curso
    local wars = country:GetCurrentWars()
    for i = 1, #wars do
        local war = wars[i]
        local warScore = war:GetWarScore(country)

        -- Verifica si el warscore supera el 100%
        if warScore >= 100 then
            return
        end

        -- Verifica si la infamia supera el límite
        local infamy = country:GetInfamy()
        if infamy >= 25 then -- Ajusta el límite de infamia según sea necesario
            return
        end

        -- Verifica el tipo de guerra
        local warGoal = war:GetWarGoal()

        -- Si el objetivo de guerra es anexión o conquista, intenta tomar provincias vecinas
        if warGoal == "annexation" or warGoal == "conquest" then
            local targetProvinces = country:GetAvailableProvincesToTake(war)
            for j = 1, #targetProvinces do
                local province = targetProvinces[j]
                -- Verifica si la provincia es vecina y no es ocupada por otro país
                if province:IsNeighbouringTo(country) and not province:IsOccupied() then
                    -- Toma la provincia si es posible
                    country:TakeProvince(province)
                end
            end
        end

        -- Gestiona la diplomacia durante la guerra según el tipo de guerra
        if warGoal == "humiliation" then
            -- Humillar al enemigo si tiene sentido
            -- country:HumiliateEnemy(war:GetEnemy())
        elseif warGoal == "sphere" then
            -- Esferar al enemigo si tiene sentido
            -- country:AddToSphere(war:GetEnemy())
        end
    end
end

function CountryAI_HandleCrisis(country, crisis)
    -- Verifica si el jugador está involucrado en la crisis
    local playerInvolved = false
    local participants = crisis:GetParticipants()
    for i = 1, #participants do
        if participants[i] == country then
            playerInvolved = true
            break
        end
    end

    -- Si el jugador no está involucrado, rechaza las propuestas de unirse a la crisis
    if not playerInvolved then
        crisis:RejectProposal(country)
        return
    end

    -- Si el jugador está involucrado, no traicionar al jugador durante la crisis
    local player = GetPlayerCountry() -- Suponiendo que hay una función para obtener el país del jugador
    if crisis:IsWar() and crisis:GetAggressor() == player then
        -- Si la crisis es una guerra y el jugador es el agresor, no traicionar al jugador
        crisis:RejectProposal(country)
    elseif crisis:IsMediation() and crisis:GetMediator() == player then
        -- Si la crisis es una mediación y el jugador es el mediador, no traicionar al jugador
        crisis:RejectProposal(country)
    elseif crisis:IsUltimatum() and crisis:GetTarget() == player then
        -- Si la crisis es un ultimátum y el jugador es el objetivo, no traicionar al jugador
        crisis:RejectProposal(country)
    end
end

function CountryAI_ResearchTechnology(country)
    -- Prioridades de investigación
    local researchPriorities = {
        "chemistry_and_electricity", -- Química y Electricidad
        "military", -- Tecnologías militares
        "political_thought", -- Estado y Gobierno (Línea de Political Thought)
        "industry", -- Industria
        "random" -- Si todas las categorías anteriores están llenas, investiga una tecnología aleatoria
    }

    -- Si el país es incivilizado, prioriza las reformas que otorgan puntos por conquistar estados
    if country:IsUncivilized() then
        local availableReforms = country:GetAvailableReforms()
        for i = 1, #availableReforms do
            local reform = availableReforms[i]
            if reform:GivesPointsForConquering() then
                country:PassReform(reform)
                return
            end
        end
    end

    -- Busca la próxima tecnología disponible según las prioridades definidas
    for i = 1, #researchPriorities do
        local priority = researchPriorities[i]
        local nextTech = country:GetNextAvailableTechnology(priority)
        if nextTech then
            country:ResearchTechnology(nextTech)
            return
        end
    end
end

-- Función para que la IA del país siempre priorice el enfoque militar
function CountryAI_PrioritizeFocus(country)
    local militaryFocusCount = 0
    while true do
        local provinces = country:GetProvinces()
        local lowestMilitaryFocusProvince
        local lowestMilitaryFocus = 1
        for i = 1, #provinces do
            local province = provinces[i]
            local militaryFocus = province:GetPops("soldiers"):GetFocus()
            if militaryFocus < lowestMilitaryFocus then
                lowestMilitaryFocusProvince = province
                lowestMilitaryFocus = militaryFocus
            end
        end
        if lowestMilitaryFocusProvince then
            country:ChangeFocus(lowestMilitaryFocusProvince, "soldiers")
            militaryFocusCount = militaryFocusCount + 1
            if militaryFocusCount >= 5 then
                break
            end
        else
            break
        end
    end
end


-- Prohibir que la AI cierre o destruya fábricas

-- Evento llamado al inicio del juego
function onStart()
    print("Script iniciado. Prohibiendo a la AI cerrar o destruir fábricas.")
end

-- Evento llamado cada mes del juego
function onMonthlyTick()
    -- Obtener la lista de provincias en el juego
    local provinces = CCurrentGameState.GetProvinces()

    -- Iterar sobre todas las provincias
    for i = 0, provinces:GetNumOfItems() - 1 do
        local province = provinces:GetItem(i)

        -- Obtener la fábrica en la provincia
        local factory = province:GetFactory()

        -- Si la fábrica está activa, prohibir a la AI cerrarla o destruirla
        if factory and factory:IsActive() then
            factory:SetCanBeClosed(false)
            factory:SetCanBeDestroyed(false)
        end
    end
end

-- Evento llamado al final del juego
function onEnd()
    print("Script finalizado. La AI no puede cerrar o destruir fábricas.")
end

-- Registra los eventos del script
OnStart = onStart
OnMonthlyTick = onMonthlyTick
OnEnd = onEnd

-- Función para que la AI tome sus cores si puede ganar la guerra
function takeCoresIfNeeded()
    local ai = CCurrentGameState.GetAI()

    -- Obtener la lista de países en el juego
    local countries = CCurrentGameState.GetCountries()

    -- Iterar sobre todos los países
    for i = 0, countries:GetNumOfItems() - 1 do
        local country = countries:GetItem(i)

        -- Verificar si el país es controlado por la AI y si tiene cores
        if country:IsAI() then
            local cores = country:GetCores()

            -- Iterar sobre los cores del país
            for j = 0, cores:GetNumOfItems() - 1 do
                local core = cores:GetItem(j)

                -- Verificar si el core es reclamado por otro país y si la AI puede ganar la guerra
                if core:IsClaimed() then
                    local targetCountry = core:GetClaimedCountry()
                    local canWinWar = ai:CanWinWar(country, targetCountry)

                    -- Si la AI puede ganar la guerra, tomar el core
                    if canWinWar then
                        core:TakeCore()
                        print("La AI de", country:GetCountryTag(), "toma su core de", targetCountry:GetCountryTag())
                    end
                end
            end
        end
    end
end

-- Función para que un imperio colonial ataque a incivilizados y países débiles en otro continente
function colonialEmpireExpansion()
    local ai = CCurrentGameState.GetAI()

    -- Obtener la lista de países en el juego
    local countries = CCurrentGameState.GetCountries()

    -- Obtener la lista de colonias controladas por la AI
    local colonies = ai:GetColonies()

    -- Iterar sobre todas las colonias controladas por la AI
    for i = 0, colonies:GetNumOfItems() - 1 do
        local colony = colonies:GetItem(i)

        -- Obtener la provincia base de la colonia
        local baseProvince = colony:GetBaseProvince()

        -- Obtener el continente de la colonia
        local continent = baseProvince:GetContinent()

        -- Si la colonia está en otro continente, buscar objetivos para la expansión colonial
        if continent ~= ai:GetHomeContinent() then
            -- Obtener la lista de países incivilizados y débiles en el continente objetivo
            local targetCountries = getCountriesInContinent(continent)

            -- Iterar sobre los países objetivo
            for j = 0, targetCountries:GetNumOfItems() - 1 do
                local targetCountry = targetCountries:GetItem(j)

                -- Verificar si la AI puede ganar una guerra contra el país objetivo
                local canWinWar = ai:CanWinWar(ai:GetCountry(), targetCountry)

                -- Si la AI puede ganar la guerra, declarar la guerra y anexar el país objetivo
                if canWinWar then
                    ai:DeclareWar(targetCountry)
                    ai:AnalyzePeace(ai:GetCountry(), targetCountry)
                    print("La AI declara la guerra a", targetCountry:GetCountryTag(), "para expandir su imperio colonial.")
                end
            end
        end
    end
end

-- Función para obtener la lista de países incivilizados y débiles en un continente
function getCountriesInContinent(continent)
    local targetCountries = CObjectList()
    local countries = CCurrentGameState.GetCountries()

    -- Iterar sobre todos los países en el juego
    for i = 0, countries:GetNumOfItems() - 1 do
        local country = countries:GetItem(i)

        -- Verificar si el país está en el continente objetivo y si es incivilizado o débil
        if country:GetProvince(1):GetContinent() == continent and (country:IsUncivilized() or country:GetMilitaryStrength() < 50) then
            targetCountries:Add(country)
        end
    end

    return targetCountries
end

-- Función para que la AI proteja sus fronteras
function protectBorders()
    local ai = CCurrentGameState.GetAI()

    -- Obtener la lista de países en el juego
    local countries = CCurrentGameState.GetCountries()

    -- Obtener el país controlado por la AI
    local aiCountry = ai:GetCountry()

    -- Obtener las provincias controladas por la AI
    local provinces = aiCountry:GetControlledProvinces()

    -- Iterar sobre todas las provincias controladas por la AI
    for i = 0, provinces:GetNumOfItems() - 1 do
        local province = provinces:GetItem(i)

        -- Obtener las provincias vecinas de la provincia actual
        local neighborProvinces = province:GetNeighbors()

        -- Iterar sobre todas las provincias vecinas
        for j = 0, neighborProvinces:GetNumOfItems() - 1 do
            local neighborProvince = neighborProvinces:GetItem(j)

            -- Obtener el país propietario de la provincia vecina
            local neighborCountry = neighborProvince:GetOwner()

            -- Verificar si la provincia vecina está controlada por otro país y si es una amenaza
            if neighborCountry ~= aiCountry and neighborCountry:GetMilitaryStrength() > aiCountry:GetMilitaryStrength() then
                -- Movilizar tropas hacia la frontera amenazada
                aiCountry:MoveUnits(province, neighborProvince, 0.5)
                print("La AI moviliza tropas hacia la frontera con", neighborCountry:GetCountryTag(), "para proteger sus fronteras.")
            end
        end
    end
end

-- Llamar a la función de protección de fronteras
protectBorders()

-- Función para hacer que la AI sea más agresiva al declarar guerras
function makeAIAggressive()
    local ai = CCurrentGameState.GetAI()

    -- Obtener la lista de países en el juego
    local countries = CCurrentGameState.GetCountries()

    -- Obtener el país controlado por la AI
    local aiCountry = ai:GetCountry()

    -- Iterar sobre todos los países en el juego
    for i = 0, countries:GetNumOfItems() - 1 do
        local country = countries:GetItem(i)

        -- Verificar si el país no es controlado por la AI y si la AI puede ganar una guerra contra él
        if country ~= aiCountry and ai:CanWinWar(aiCountry, country) then
            -- Si la AI no tiene un tratado de no agresión con el país objetivo, declarar la guerra
            if not aiCountry:HasNonAggressionPact(country) then
                ai:DeclareWar(country)
                print("La AI declara la guerra a", country:GetCountryTag())
            end
        end
    end
end

-- Llamar a la función para hacer que la AI sea más agresiva
makeAIAggressive()

-- Función para que la AI priorice la esfera para sus países formables
function prioritizeSphereForFormables()
    local ai = CCurrentGameState.GetAI()

    -- Obtener la lista de países en el juego
    local countries = CCurrentGameState.GetCountries()

    -- Obtener el país controlado por la AI
    local aiCountry = ai:GetCountry()

    -- Obtener los países formables por la AI
    local formableCountries = ai:GetFormableCountries()

    -- Iterar sobre todos los países formables
    for i = 0, formableCountries:GetNumOfItems() - 1 do
        local formableCountry = formableCountries:GetItem(i)

        -- Verificar si el país formable puede ser esferado
        if aiCountry:CanSphere(formableCountry) then
            -- Esferar el país formable a nivel 3
            aiCountry:AddToSphere(formableCountry, 3)
            print("La AI esfera a", formableCountry:GetCountryTag(), "a nivel 3")
        end
    end
end

-- Llamar a la función para que la AI priorice la esfera para sus países formables
prioritizeSphereForFormables()

-- custom_functions.lua