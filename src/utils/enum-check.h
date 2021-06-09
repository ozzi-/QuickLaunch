#ifndef ENUM_CHECK
#define ENUM_CHECK
/*

template<typename EnumType, EnumType V, EnumType... Next>
class EnumCheck<EnumType, V, Next...> : private EnumCheck<EnumType, Next...>
{
    using super = EnumCheck<EnumType, Next...>;

public:
    template<typename IntType>
    static bool constexpr is_value(IntType v)
    {
        return v == static_cast<IntType>(V) || super::is_value(v);
    }
    static EnumType constexpr parse(int x){
        return static_cast<EnumType>(x);
    }
};*/

#endif