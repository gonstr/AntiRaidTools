function AntiRaidTools:ParseImport(import)
    -- Parse as YAML
    if text == nil or string.len(text) == 0 then
        return false
    end

    local ok, result = pcall(AntiRaidTools.YAML.evalm, text)
end
