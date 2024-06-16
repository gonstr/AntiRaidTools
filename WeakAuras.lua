local WA_ANTI_RAID_TOOLS_HELPER = "!WA:2!9rvtVnory4n0dGSqll5qK4JdwbPsROebDzxKQ0k24Uo7wu6h44(bcH8o2ZRJh6KzSMzC2MfXLioW5YzUKZCk34kh4Svf)c6pH9xaVJDtuPSLrkz(WpZ7hpVVZtJEnh1K2K(lFSswy4mbO2)WW(7SNV6S9tt1GPXCktNZjtcHZmVXf6mcv(IVT(BF4DMtejzs1bsMWeVT)EH(b5Ux7crPs1iIjkpYWgbxTRr(9sk0g5ilIdZPedeaJbH5ssbEkXWsoMrnzEDXTksIHjf6hgOneLXjoLjy6mhpCYS65uzuTTEEC98zn0Su3(S4bMIyxtgiCCXbxMq4UDtaFRJCF0ceR1EXzF6978zTxVcC1FOvwcFPzSdsHIebIXDQIznARF8Nw(Xfxzl)rXaDTBGD9L4IE631URWWcimAOuY1rh3n6zaphur9LekqB)9OLnQcO6oGG6y)5S0IdWT7cAnziGatlev80AvoAd3oD6S(I04Mb8)x2S11mlYnbH24Y)iSY2Ed3BA7LbLZuJInCiO03Dv1vl)lpZKCOS5L6I4QloOinLD28OT7oimAqiA7sN4NbeUjBjMduaIjyWb(977vGv4yBNeOQ)Q(smy27WD93lkCND9dMQZboFhQ2jqqgb4usgKCAPZ86EHiBemh7BmqrvBwzZ8)yjtf9FtiKSG6(Jh52(F7R23cTDD(61Xpl7NEcm2wO3QlL(eIHS2Xa50UOv0BGUAX6R3aQatHs4Ms4AWsZZOqmsHHyoPEMF)d6Dy)ZlexX2o5VR9HYyiSE)Usk873jV9T)wCKKgPqo555RE7G4WqsYKOuUuQYoxd806N6E7hgU)UEPsHj)E9uSx6(nfekAoIBy4mSAgadTVAF)wLTUa3gtsoDikXiOECS7(OZl0qKa5lvwSHWrARvWOcUHHLqorRBv(ahpS6MuVG9sWUyQ1FdWnV3v6qNuRdTYmvL7SuJNbZI8p52tj6eSxHLezYuGotYPtoNiywvhP4HL3T3FcenmWOaXqt2Bw2YtifWfuS6yru1sP0qIuq1tTqToT8XEJimrVYVcVq5Jl7w6vUno)o38K8p62dSCfKW0Opwj)dETOQxeybtNzdawLYOZ0xiv0JvK8PhF1c1pG9)S0jE997foZitqI2A5363kBZO5TSkpUwPh3kTh3AHh1Kfs(Pk85eYby9CLxvlX3ZEKnxJhSDGV)EXyaKYg6SzbJoFZt2S)xMo(PQEFXfOgocF)86ylirYLQVEfCmVUMTD1bnA0yLz4tDGwj1)ZV9CMOo)WR58kShducc)O64(xBQJFqNp)(D2S54)(K)5"

function AntiRaidTools:IsWeakAurasInstalled()
    return WeakAuras ~= nil
end

function AntiRaidTools:IsHelperWeakauraInstalled()
    if not self:IsWeakAurasInstalled() then
        return false    
    end 

    if not WeakAurasSaved then
        return false
    end

    for _, wa in pairs(WeakAurasSaved.displays) do
        if wa.id == "Anti Raid Tools Helper" then
            return true
        end
    end

    return false
end

function AntiRaidTools:InstallHelperWeakAura(callback)
    if WeakAuras then
        WeakAuras.Import(WA_ANTI_RAID_TOOLS_HELPER, nil, callback)
    end
end
