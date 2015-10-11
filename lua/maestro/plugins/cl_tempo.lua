local function escape(str)
	str = str:gsub("<", "&lt;")
	str = str:gsub(">", "&gt;")
	return str:gsub("(['\"])", "\\%1")
end
local function abbr(str)
    str = str:gsub("and ", "")
    str = str:gsub(",", "")
    str = str:gsub(" months?", "M")
    str = str:gsub(" weeks?", "w")
    str = str:gsub(" days?", "d")
    str = str:gsub(" hours?", "h")
    str = str:gsub(" minutes?", "m")
    str = str:gsub(" seconds?", "s")
    return str
end

local jointime = CurTime()
local cooldown = 0
local lastply
maestro.hook("Think", "maestro-tempo", function()
    if not IsValid(maestro_tempo) then return end

    local time = CurTime() - LocalPlayer():GetNWInt("maestro-tempo", CurTime())
    local str = maestro.time(time, -5)
    local join = maestro.time(CurTime() - jointime, -5)
    maestro_tempo:Call([[
document.getElementById("panel-title").innerHTML = "Total: ]] .. abbr(str) .. [[<br>Current: ]] .. abbr(join) .. [[";
]])

    cooldown = cooldown - FrameTime()
    local tr = LocalPlayer():GetEyeTrace()
    if type(tr.Entity) == "Player" and not tr.Entity:GetNWBool("disguised", false) then
        cooldown = 3
        lastply = tr.Entity
    elseif cooldown <= 0 then
        lastply = nil
        maestro_tempo:Call([[
$('.collapse').collapse("hide");
]])
    end
    if IsValid(lastply) then
        local plytime = abbr(maestro.time(CurTime() - lastply:GetNWInt("maestro-tempo", CurTime()), -5))
        maestro_tempo:Call([[
$('.collapse').collapse("show");
document.getElementById("panel-body").innerHTML = "Name: ]] .. lastply:Nick() .. [[<br>SteamID: ]] .. lastply:SteamID() .. [[<br>Total: ]] .. plytime .. [[";
]])
    end
end)

if maestro_tempo then
    maestro_tempo:Remove()
end
timer.Create("maestro_tempo", 1, 0, function()
	maestro_tempo = vgui.Create("DHTML")
	if not maestro_tempo then
		return
	else
		timer.Remove("maestro_tempo")
	end
	maestro_tempo:SetSize(280, 180)
	maestro_tempo:SetPos(ScrW() - 280 - 40, 180)
	maestro_tempo:SetHTML([[
<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="utf-8">
	<title>Bootstrap 3</title>
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<meta name="description" content="">
	<meta name="author" content="">

	<!--link rel="stylesheet/less" href="less/bootstrap.less" type="text/css" /-->
	<!--link rel="stylesheet/less" href="less/responsive.less" type="text/css" /-->
	<!--script src="js/less-1.3.3.min.js"></script-->
	<!--append ‘#!watch’ to the browser URL, then refresh the page. -->

	<link rel="stylesheet" href=" https://maxcdn.bootstrapcdn.com/bootstrap/3.3.4/css/bootstrap.min.css">



	<!-- Latest compiled and minified JavaScript -->
	<script src=" https://ajax.googleapis.com/ajax/libs/jquery/1.11.2/jquery.min.js"></script>
	<script src=" https://maxcdn.bootstrapcdn.com/bootstrap/3.3.4/js/bootstrap.min.js"></script>

	<style>
		.noselect {
			-webkit-touch-callout: none;
			-webkit-user-select: none;
			-khtml-user-select: none;
			-moz-user-select: none;
			-ms-user-select: none;
			user-select: none;
			cursor:default;
		}
		.form-control-inline {
			min-width: 0;
			width: auto;
			display: inline;
		}
		.affix {
			width: 809px;
		}
		body {
			background-color: transparent;
		}
		.nopad {
			padding-bottom: 0px;
		}
	</style>
</head>
<body>
	<div class="container">
		<div class="row clearfix">
            <div class="col-md-12">
                <div class="panel panel-primary" id="panel">
                    <div class="panel-heading">
                        <h3 class="panel-title" id="panel-title">
                            Total: 14w 3d 22h 22m 56s<br>
                            Session: 00w 0d 22h 22m
                        </h3>
                    </div>
                    <div id="collapse" class="panel-collapse collapse in">
                        <div class="panel-body" id="panel-body">
                            Panel content
                        </div>
                    </dive>
                </div>
            </div>
		</div>
	</div>
</body>
]])
end)
