local userInterface = game:GetService("UserInterface")

-- Créez ou référez votre menu déplacable ici. Assurez-vous qu'il soit déjà dans votre jeu Roblox.
local sideMenu = --[Enter your sideMenu instance here]--

if not sideMenu then 
    warn("SideMenu not found, please create a ScreenGui and put it in the UserInterface service.")
    return
end

-- Créez un bouton et ajoutez-le à votre menu déplacable.
local kickButton = Instance.new("TextButton")
kickButton.Size = UDim2(0.15, 0) -- Hauteur: 15% de l'élément parent, Largeur: ajuster selon vos besoins
kickButton.Position = UDim2(0.42, 0) -- Position relative au menu déplacable

-- Texte du bouton
kickButton.Text = "Déclencher l'Event"
kickButton.FontSize = Enum.FontSize.Size14
kickButton.TextColor3 = Color3.new(1, 1, 1)
kickButton.BackgroundColor3 = Color3.new(0.4, 0.5, 0.6)

-- Ajoutez le bouton à votre menu déplacable.
kickButton.Parent = sideMenu

-- Fonction appelée lorsque l'utilisateur clique sur le bouton
local function triggerKickEvent()
    local Event = game:GetService("ReplicatedStorage").Shared.Packages.Network.rev_KickEvent -- Assurez-vous que ce service est bien configuré
    Event:FireServer(1, 1)
    
    callRevBallKick(27) -- Appel de la fonction pour déclencher le processus après délai.
end

-- Fonction appelée par le bouton
kickButton.MouseButton1Click:Connect(triggerKickEvent)

-- La fonction d'appel récursif pour l'événement rev_ballKick
function callRevBallKick(delay)
    local countdown = delay
    while countdown ~= 0 do
        wait(1) -- Attend une seconde
        countdown = countdown - 1
    end
    
    local Event = game:GetService("ReplicatedStorage").Shared.Packages.Network.rev_ballKick

    -- Appel de l'événement rev_ballKick avec le numéro spécifié.
    Event:FireServer(100)
    
    -- Appeler rev_KickEvent à partir de 100 jusqu'à 1 en diminuant d'un par tour
    for i = 100, 1, -1 do
        wait(delay) -- Attend le délai avant chaque appel
        if i > 0 then
            Event:FireServer(i)
        end
    end
end

-- Initialisation du processus de kick.
triggerKickEvent()
