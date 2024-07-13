local AntiFrames = AntiFrames

local WA_ANTI_RAID_TOOLS_HELPER = "!WA:2!9v1tVnoru8n0dWAbR2wPTs8NdwbPQwrByPlSiwP9qDLZ2Is)doUTlcH8o2ZZXdR9mJMzC2MfXLioW5YzUKZCkFe4aNTQ4tq)iSFc4n2PrLcblL45n537nV3V3B(LwDxPyf6k0FzDLO0KZ4G6Otc7T)H(QZpknvdMwxQZiuXR(2gZp6otj8KmH6ybJBI31)Wq)aPlLPL5KrHW5MOuHQGyIKrgwbmZQL8(jLAJOWI4ejLyGayiWnxrkXDjgwYzmQjZBh0ursmmbx)4aTHOmoXPmotN54HVmRDbve1eRxe38(8wAwQBpwCFtzSRjd4oU4tUiHK7Utc4Bpi3NEnI1BF9EB9OopS9g1GR)cJYC4ZdJ9HuQiraFyN6CwJX6h)P5)41U8e)IyGU(TWUXCCrp77AVd3WcimAOqKRJoBNO9GCjOI6jiuG2(7XiBuLqTpaN6y)4mpI9rZdaTMmaqGPL8AEA96dAt3oD6SX1LXTt4)VQ5j3iSi3eeAZl)tXoB7nDVDSNNuoJnk2GbGsFV1uZw(NEMrsOA5R0LX1o2VmnLD(0OD3PFyu)qm2v3nEpGKBYMJ5yfGyc6FSFVEELyho2ojbQXAjKNVpv70GtFfMwhEYb(hgfU)b(bbCsbODcsYGKxwD3PnZcr2myko3yGY6XSQLLQ5mv0)UGqYcAMpEQB7)5j0Eb02n5RfWptOqmw7HyYO2ZV3XDpP3fL8z0KJCz7e(qiSX(abf(97iBV4lrfcAKclMx8g8shO4K8trIhROF9ccNzV(i4pU696(hard9nkGpWK92vpWJl4WLumXTiQ5gLgseCQESfQn)Q2YRGW4DR2eDOARQovFA1dX337274Lk4g597QyV29BkjumOe3WWjyJmagyVW(bRw9GlrZysYlhGckCQxooyF6fLAiIJuLkl2qYrgB1GIYCdd7E5eTE1QVYXdB3jnlyVgSlgBpV(OX7hRfLQeiMvifkZmbPN3iiT0ev9HBlfpdsDY1wmpMddijJIsZfcvMA0mfUjwcHvl54i)4f7TubjmlRVK8twmk6iCWKLezYuGotKthDjQXHkMhjBoIP3W33s9d4yllDKxp)UHtmIKHnn2353QAZOYvTcgUwfd3Ajd3g9IymJtzdCMMQWlbydhBfl9MgH5U2TSSrC)Dd89pu(H)N5AZIaBkt3UKrNU9Z3U3xMo8zQUF(4xju0Zue54ZMTiirKluF9s4Z0g6F36nA1Q1stWRVaTw((NF3PmEtKXAW5cnKN28hfEhfgE0bROJ)IoF2J6S9kd)RN)3p"

function AntiRaidTools:WeakAurasIsInstalled()
    return WeakAuras ~= nil
end

function AntiRaidTools:WeakaurasIsHelperInstalled()
    if not self:WeakAurasIsInstalled() then
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

function AntiRaidTools:WeakAurasInstallHelper(callback)
    if WeakAuras then
        WeakAuras.Import(WA_ANTI_RAID_TOOLS_HELPER, nil, callback)
    end
end
