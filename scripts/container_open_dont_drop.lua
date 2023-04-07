AddClassPostConstruct(
        "components/container",
        function(self)
            if not GLOBAL.TheWorld.ismastersim then
                return
            end
            self.inst:DoTaskInTime(
                    0,
                    function()
                        if self.droponopen == true then
                            self.droponopen = false
                        end
                    end
            )
        end
)