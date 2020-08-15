-- modified from lyric-exporter.lua by @emako
-- consider adding https://rosettacode.org/wiki/Word_wrap#Lua

local tr = aegisub.gettext
script_name = tr"Export WebVTT File"
script_description = tr"Export WebVTT For Aegisub"
script_author = "brian"
script_version = "1"

local function strip_tags(text)
	text = text:gsub('{[^}]+}', '')
	text = text:gsub('\\N', '')
	text = text:gsub('\\n', '')
	text = text:gsub('\\h', ' ')
	return text
end

local function vtt_header()
	return table.concat( {
		'WEBVTT',
	} )
end

local function to_timecode(time_ms)
	time_sec = time_ms / 1000
	h = math.floor(time_sec / 3600)
	m = math.floor(time_sec % 3600 / 60)
	s = math.floor(time_sec % 60)
	ms = time_ms % 1000
	
	return string.format('%02d:%02d:%02d.%03d', h, m, s, ms)
end

local function to_vtt_line(start_time, end_time, text)
	start_tc = to_timecode(start_time)
	end_tc = to_timecode(end_time)

	return string.format('%s --> %s\n%s', start_tc, end_tc, text)
	-- 00:00:00.000 --> 00:00:01.500
	-- subtitle text
end

local function endswith(str, substr)
	if str == nil or substr == nil then
		return false
	end
	str_tmp = string.reverse(str)
	substr_tmp = string.reverse(substr)
	if string.find(str_tmp, substr_tmp) ~= 1 then
		return false
	else
		return true
	end
end

function ass_to_vtt(subs, sel)
	local filename = aegisub.dialog.save('Save WebVTT File', '', '', 'WebVTT File(*vtt)|*vtt')
	
	if not filename then
		aegisub.cancel()
	end
	
	if endswith(string.lower(filename), '.vtt') == false then
		filename = filename .. '.vtt'
	end

	local output_file = io.open(filename, 'w+')
	if not output_file then
		aegisub.debug.out('Failed to open file')
		aegisub.cancel()
	end

	output_file:write(vtt_header())

	line_count = 1 -- first six lines are non-dialog / header info
	for i = 1, #subs, 1 do
		local line = subs[i]
		if line.class == 'dialogue' then
			output_file:write(string.format('\n\n%s\n', line_count))
			output_file:write(to_vtt_line(line.start_time, line.end_time, strip_tags(line.text)))
			line_count = line_count + 1
		end
	end

	output_file:close()
end

aegisub.register_macro(script_name, script_description, ass_to_vtt)
