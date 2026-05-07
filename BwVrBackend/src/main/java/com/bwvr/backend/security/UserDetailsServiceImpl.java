package com.bwvr.backend.security;

import com.bwvr.backend.entity.BwvrUser;
import com.bwvr.backend.repository.BwvrUserRepository;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

@Service
public class UserDetailsServiceImpl implements UserDetailsService {
    
    private final BwvrUserRepository userRepository;

    public UserDetailsServiceImpl(BwvrUserRepository userRepository) {
        this.userRepository = userRepository;
    }

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
<<<<<<< HEAD
        BwvrUser user = userRepository.findByUsername(username)
=======
        String normalizedUsername = username != null ? username.trim().toLowerCase() : "";
        BwvrUser user = userRepository.findByUsername(normalizedUsername)
>>>>>>> 84141aa47c8b58ff717d8d2c62f72a0cee589238
                .orElseThrow(() -> new UsernameNotFoundException("User Not Found with username: " + username));

        return UserDetailsImpl.build(user);
    }
}
